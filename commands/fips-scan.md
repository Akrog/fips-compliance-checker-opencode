---
description: Scan project or container image for FIPS 140-3 compliance violations
agent: fips-compliance-checker
---

Perform a comprehensive FIPS 140-3 compliance audit for containerized applications running on Red Hat Enterprise Linux 9 (or later).

If an argument was provided (`$ARGUMENTS`), treat it as a container image reference and audit that image; otherwise audit the current project.

Scan for:

- Non-compliant cryptographic libraries and dependencies
- Prohibited or deprecated algorithms (MD5, SHA-1, DES, 3DES, RC4, etc.)
- Non-FIPS approved algorithms (Blake3, ChaCha20, Curve25519, etc.)
- Cryptographic operations that bypass RHEL's FIPS-certified boundary
- Configuration issues affecting FIPS compliance
- Container base image compliance
- Build system settings that may impact FIPS mode

Provide:

- Detailed compliance report with severity levels (CRITICAL, HIGH, MEDIUM, LOW)
- Specific file locations and line numbers for violations
- Actionable remediation steps with code examples
- Compliance score breakdown
- Verification commands to confirm compliance
