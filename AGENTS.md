# AGENTS.md

This file provides guidance to OpenCode when working with this repository.

## Repository Purpose

This repository contains the **FIPS Compliance Checker** for OpenCode — a port of
the [Claude Code plugin](https://github.com/opendatahub-io/fips-compliance-checker-claude-code-plugin)
(the `upstream` git remote). It provides FIPS 140-3 compliance auditing
capabilities for containerized applications running on Red Hat Enterprise Linux
9 (or later).

## Repository Structure

```
fips-compliance-checker-opencode/
├── agents/
│   └── fips-compliance-checker.md    # OpenCode subagent definition
├── commands/
│   └── fips-scan.md                  # /fips-scan command
├── scripts/
│   └── python/                       # Python scanning tools
│       ├── scan-python-fips.sh
│       ├── lib/                      # Scanning library scripts
│       └── patterns/                 # Detection patterns
├── tests/                            # Integration tests
├── AGENTS.md                         # This file
└── README.md                         # User documentation
```

## Components

### Agent: fips-compliance-checker

**File**: `agents/fips-compliance-checker.md`
**ID**: `fips-compliance-checker` (mode: subagent)

The agent performs comprehensive FIPS 140-3 compliance auditing including:
- Scanning source code for cryptographic operations
- Analyzing dependencies for non-compliant libraries
- Detecting prohibited or non-approved algorithms
- Verifying container configurations
- Generating compliance reports with remediation guidance

**Invocation triggers**:
- User mentions cryptographic operations, encryption, hashing, or TLS/SSL
- User discusses container images for Red Hat products or RHEL deployments
- User mentions FIPS, compliance, or security certifications
- User is working with crypto libraries in Java, Python, Go, Rust, or C/C++

### Command: fips-scan

**File**: `commands/fips-scan.md`
**Invocation**: `/fips-scan [image]`

Explicit invocation for FIPS compliance scanning with optional container image
argument. Runs the `fips-compliance-checker` agent in a child session.

## Working with the FIPS Agent

The FIPS agent follows a strict 5-phase scanning process:
1. Dependency Analysis
2. Source Code Analysis
3. Configuration Review
4. Integration Points
5. Report Generation

**Output includes**:
- Compliance score (0-100) with breakdown by category
- JSON findings with severity, location, and remediation
- Verification commands

**Severity Levels**:
- CRITICAL: Direct FIPS boundary violations
- HIGH: Security-critical operations using non-compliant algorithms
- MEDIUM: Approved algorithms without provider verification
- LOW: Configuration improvements or best practices

### Suppressing Findings via AGENTS.md

Developers can suppress specific findings by adding a FIPS section to their
project's `AGENTS.md`. The agent reads this file at scan start and honours any
suppression instructions. Suppressed findings are reported with
`"status": "SUPPRESSED"` in JSON output and are excluded from the compliance
score.

See `README.md` for examples and guidance.

## Development Guidelines

### Modifying the Agent

1. Edit `agents/fips-compliance-checker.md`
2. Test with sample projects in `tests/fixtures/`
3. Update documentation as needed
4. When changing suppression-related behaviour, verify that suppressed findings are
   never silently dropped — they must appear in output with `"status": "SUPPRESSED"`

The agent prompt invokes the Python scanner via this repository's absolute path
(`~/code/fips-compliance-checker-opencode/scripts/python/scan-python-fips.sh`).
If the repository moves, update that path in the agent prompt.

### Adding Scanning Capabilities

1. Add scripts to `scripts/python/lib/` for new analysis
2. Update pattern files in `scripts/python/patterns/`
3. Integrate into `scripts/python/scan-python-fips.sh`
4. Add test fixtures and update test suite

### Running Tests

```bash
./tests/test-python-scanner.sh
```

## Agent Prompt Format

Agent prompts use YAML frontmatter for configuration. OpenCode fields:

```markdown
---
description: When to invoke this agent, with examples
mode: subagent
color: "#ff6b6b"
---

# Agent system prompt goes here
```

**Critical Sections for Agent Prompts**:
- Clear invocation criteria with user/assistant dialogue examples
- Detailed operating procedures and scanning phases
- Structured output format specifications
- Quality assurance checklists
