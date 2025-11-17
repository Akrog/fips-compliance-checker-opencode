#!/bin/bash
# Layer 4: Runtime FIPS Verification
# Checks Python runtime environment for FIPS compliance

set -euo pipefail

# Check if Python cryptography library is FIPS-enabled
check_cryptography_fips() {
    local result
    result=$(python3 -c "
import json
import sys

try:
    from cryptography.hazmat.backends.openssl import backend

    fips_enabled = backend._fips_enabled
    openssl_version = backend.openssl_version_text()

    print(json.dumps({
        'fips_enabled': fips_enabled,
        'openssl_version': openssl_version,
        'status': 'PASS' if fips_enabled else 'FAIL',
        'check': 'cryptography_fips_status'
    }))
except ImportError as e:
    print(json.dumps({
        'error': f'cryptography library not available: {str(e)}',
        'status': 'UNKNOWN',
        'check': 'cryptography_fips_status'
    }))
except Exception as e:
    print(json.dumps({
        'error': str(e),
        'status': 'ERROR',
        'check': 'cryptography_fips_status'
    }))
" 2>&1)

    echo "$result"
}

# Check OpenSSL version and FIPS capability
check_openssl_version() {
    local result
    result=$(python3 -c "
import json
import ssl

try:
    version = ssl.OPENSSL_VERSION
    version_info = ssl.OPENSSL_VERSION_INFO

    # OpenSSL 3.x is required for FIPS on RHEL 9
    is_openssl3 = version_info[0] >= 3

    print(json.dumps({
        'openssl_version': version,
        'version_major': version_info[0],
        'version_minor': version_info[1],
        'is_openssl3': is_openssl3,
        'status': 'PASS' if is_openssl3 else 'FAIL',
        'check': 'openssl_version'
    }))
except Exception as e:
    print(json.dumps({
        'error': str(e),
        'status': 'ERROR',
        'check': 'openssl_version'
    }))
" 2>&1)

    echo "$result"
}

# Check if cryptography library links to system OpenSSL (not bundled)
check_openssl_linkage() {
    local result
    result=$(python3 -c "
import json
import sys

try:
    from cryptography.hazmat.bindings import _openssl
    import os

    # Get path to the _openssl binding
    openssl_path = _openssl.__file__

    print(json.dumps({
        'openssl_binding_path': openssl_path,
        'check': 'openssl_linkage'
    }))
except ImportError:
    print(json.dumps({
        'error': 'cryptography library not available',
        'status': 'UNKNOWN',
        'check': 'openssl_linkage'
    }))
except Exception as e:
    print(json.dumps({
        'error': str(e),
        'status': 'ERROR',
        'check': 'openssl_linkage'
    }))
" 2>&1)

    echo "$result"

    # If we got a path, check with ldd
    local binding_path
    binding_path=$(echo "$result" | jq -r '.openssl_binding_path // empty' 2>/dev/null || true)

    if [ -n "$binding_path" ] && [ -f "$binding_path" ]; then
        local ldd_output
        ldd_output=$(ldd "$binding_path" 2>/dev/null | grep -E 'libssl|libcrypto' || echo "")

        if [ -n "$ldd_output" ]; then
            # Check if linked to system libraries (typically in /lib64 or /usr/lib64)
            local system_linked=false
            if echo "$ldd_output" | grep -qE '/(lib64|usr/lib64|lib/x86_64-linux-gnu|lib/aarch64-linux-gnu)/'; then
                system_linked=true
            fi

            echo "{\"ldd_output\": $(echo "$ldd_output" | jq -R -s '.'), \"system_linked\": $system_linked, \"check\": \"openssl_linkage_detail\"}"
        fi
    fi
}

# Check for bundled OpenSSL in site-packages (violation)
check_bundled_openssl() {
    local result
    result=$(python3 -c "
import json
import site
import os
import glob

try:
    site_packages = site.getsitepackages()
    bundled_libs = []

    for site_pkg in site_packages:
        # Look for bundled OpenSSL libraries
        for pattern in ['libssl*.so*', 'libcrypto*.so*', 'libssl*.dylib', 'libcrypto*.dylib']:
            libs = glob.glob(os.path.join(site_pkg, '**', pattern), recursive=True)
            bundled_libs.extend(libs)

    has_bundled = len(bundled_libs) > 0

    print(json.dumps({
        'bundled_openssl_found': has_bundled,
        'bundled_libraries': bundled_libs,
        'status': 'FAIL' if has_bundled else 'PASS',
        'check': 'bundled_openssl'
    }))
except Exception as e:
    print(json.dumps({
        'error': str(e),
        'status': 'ERROR',
        'check': 'bundled_openssl'
    }))
" 2>&1)

    echo "$result"
}

# Check if Python is running with PYTHONHASHSEED set (can affect determinism)
check_python_environment() {
    local hash_seed="${PYTHONHASHSEED:-not_set}"
    local in_venv="false"

    # Check if in virtual environment
    if python3 -c "import sys; sys.exit(0 if sys.prefix != sys.base_prefix else 1)" 2>/dev/null; then
        in_venv="true"
    fi

    cat <<EOF
{
  "pythonhashseed": "$hash_seed",
  "in_virtual_environment": $in_venv,
  "python_version": "$(python3 --version 2>&1 | cut -d' ' -f2)",
  "check": "python_environment"
}
EOF
}

# Generate compliance findings based on runtime checks
generate_runtime_findings() {
    local fips_status="$1"
    local openssl_ver="$2"
    local linkage="$3"
    local bundled="$4"
    local findings=()

    # Check FIPS status
    local fips_enabled
    fips_enabled=$(echo "$fips_status" | jq -r '.fips_enabled // false')

    if [ "$fips_enabled" != "true" ]; then
        local severity="CRITICAL"
        local fips_error
        fips_error=$(echo "$fips_status" | jq -r '.error // "FIPS mode not enabled"')

        if echo "$fips_status" | jq -e '.error' >/dev/null 2>&1; then
            severity="HIGH"
        fi

        findings+=($(cat <<EOF
{
  "id": "RUNTIME-001",
  "severity": "$severity",
  "category": "RUNTIME",
  "status": "FAIL",
  "detection": {
    "type": "FIPS_STATUS",
    "name": "cryptography_library_fips_mode",
    "confidence": "HIGH"
  },
  "compliance": {
    "violation": "Cryptography library not running in FIPS mode",
    "fips_section": "140-3:7.5.1",
    "rhel_requirement": "System must be in FIPS mode, cryptography must use FIPS provider",
    "risk_profile": "CRYPTOGRAPHIC_BOUNDARY"
  },
  "remediation": {
    "action": "CONFIGURE",
    "priority": "IMMEDIATE",
    "effort": "MEDIUM",
    "recommendation": "Enable FIPS mode: sudo fips-mode-setup --enable && sudo reboot",
    "verification_command": "fips-mode-setup --check && python3 -c 'from cryptography.hazmat.backends.openssl import backend; print(backend._fips_enabled)'"
  }
}
EOF
))
    fi

    # Check for bundled OpenSSL
    local has_bundled
    has_bundled=$(echo "$bundled" | jq -r '.bundled_openssl_found // false')

    if [ "$has_bundled" == "true" ]; then
        local bundled_libs
        bundled_libs=$(echo "$bundled" | jq -c '.bundled_libraries // []')

        findings+=($(cat <<EOF
{
  "id": "RUNTIME-002",
  "severity": "CRITICAL",
  "category": "RUNTIME",
  "status": "FAIL",
  "detection": {
    "type": "BUNDLED_CRYPTO",
    "name": "bundled_openssl_libraries",
    "confidence": "HIGH",
    "libraries": $bundled_libs
  },
  "compliance": {
    "violation": "Bundled OpenSSL libraries found in site-packages",
    "fips_section": "140-3:7.5.1",
    "rhel_requirement": "Must use system OpenSSL, not bundled versions",
    "risk_profile": "CRYPTOGRAPHIC_BOUNDARY"
  },
  "remediation": {
    "action": "REPLACE",
    "priority": "IMMEDIATE",
    "effort": "HIGH",
    "recommendation": "Reinstall cryptography package from system repos or ensure it links to system OpenSSL",
    "verification_command": "ldd \$(python3 -c 'from cryptography.hazmat.bindings import _openssl; print(_openssl.__file__)') | grep libssl"
  }
}
EOF
))
    fi

    # Check OpenSSL version
    local is_openssl3
    is_openssl3=$(echo "$openssl_ver" | jq -r '.is_openssl3 // false')

    if [ "$is_openssl3" != "true" ]; then
        local ssl_version
        ssl_version=$(echo "$openssl_ver" | jq -r '.openssl_version // "unknown"')

        findings+=($(cat <<EOF
{
  "id": "RUNTIME-003",
  "severity": "HIGH",
  "category": "RUNTIME",
  "status": "FAIL",
  "detection": {
    "type": "OPENSSL_VERSION",
    "name": "openssl_version_check",
    "confidence": "HIGH",
    "version": "$ssl_version"
  },
  "compliance": {
    "violation": "OpenSSL 3.x required for FIPS on RHEL 9",
    "fips_section": "140-3:7.5.1",
    "rhel_requirement": "RHEL 9 requires OpenSSL 3.x with FIPS provider",
    "risk_profile": "CRYPTOGRAPHIC_BOUNDARY"
  },
  "remediation": {
    "action": "UPDATE",
    "priority": "HIGH",
    "effort": "MEDIUM",
    "recommendation": "Upgrade to RHEL 9 or ensure OpenSSL 3.x is installed",
    "verification_command": "openssl version"
  }
}
EOF
))
    fi

    # Output findings
    if [ ${#findings[@]} -gt 0 ]; then
        printf '%s\n' "${findings[@]}" | jq -s '.'
    else
        echo "[]"
    fi
}

# Main function
main() {
    echo "# Performing runtime FIPS verification..." >&2

    local fips_status
    local openssl_ver
    local linkage
    local bundled
    local env_info

    fips_status=$(check_cryptography_fips)
    openssl_ver=$(check_openssl_version)
    linkage=$(check_openssl_linkage)
    bundled=$(check_bundled_openssl)
    env_info=$(check_python_environment)

    # Generate findings
    local findings
    findings=$(generate_runtime_findings "$fips_status" "$openssl_ver" "$linkage" "$bundled")

    # Output complete runtime verification results
    cat <<EOF
{
  "runtime_checks": {
    "fips_status": $fips_status,
    "openssl_version": $openssl_ver,
    "openssl_linkage": $linkage,
    "bundled_openssl": $bundled,
    "environment": $env_info
  },
  "findings": $findings
}
EOF
}

# If sourced, don't run main
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
