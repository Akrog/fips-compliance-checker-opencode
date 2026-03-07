# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Purpose

This repository contains the **FIPS Compliance Checker** plugin for Claude Code. It provides FIPS 140-3 compliance auditing capabilities for containerized applications running on Red Hat Enterprise Linux 9 (or later).

## Repository Structure

```
fips-compliance-checker/
├── .claude-plugin/
│   └── plugin.json               # Plugin metadata
├── agents/
│   └── fips-compliance-checker.md    # Agent definition
├── commands/
│   └── fips-scan.md              # Slash command
├── scripts/
│   └── python/                   # Python scanning tools
│       ├── scan-python-fips.sh
│       ├── lib/                  # Scanning library scripts
│       └── patterns/             # Detection patterns
├── tests/                        # Integration tests
├── CLAUDE.md                     # This file
└── README.md                     # User documentation
```

## Plugin Components

### Agent: fips-compliance-checker

**File**: `agents/fips-compliance-checker.md`
**Full Reference**: `fips-compliance-checker:fips-compliance-checker`

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

### Slash Command: fips-scan

**File**: `commands/fips-scan.md`
**Invocation**: `/fips-compliance-checker:fips-scan [image]`

Explicit invocation for FIPS compliance scanning with optional container image argument.

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

### Suppressing Findings via CLAUDE.md

Developers can suppress specific findings by adding a FIPS section to their project's
`CLAUDE.md`. The agent reads this file at scan start and honours any suppression
instructions. Suppressed findings are reported with `"status": "SUPPRESSED"` in JSON
output and are excluded from the compliance score.

See `README.md` for examples and guidance.

## Development Guidelines

### Modifying the Agent

1. Edit `agents/fips-compliance-checker.md`
2. Test with sample projects in `tests/fixtures/`
3. Update documentation as needed
4. When changing suppression-related behaviour, verify that suppressed findings are
   never silently dropped — they must appear in output with `"status": "SUPPRESSED"`

### Adding Scanning Capabilities

1. Add scripts to `scripts/python/lib/` for new analysis
2. Update pattern files in `scripts/python/patterns/`
3. Integrate into `scripts/python/scan-python-fips.sh`
4. Add test fixtures and update test suite

### Running Tests

```bash
./tests/test-python-scanner.sh
```

## External Reference

Other Claude Code marketplaces can reference this plugin via Git URL.

### In marketplace.json

```json
{
  "name": "my-marketplace",
  "plugins": [
    {
      "name": "fips-compliance-checker",
      "source": "git@gitlab.cee.redhat.com:gryan/gryan-claude-plugins.git",
      "description": "FIPS 140-3 compliance auditing for RHEL 9+"
    }
  ]
}
```

### Via HTTPS

```json
{
  "source": "https://gitlab.cee.redhat.com/gryan/gryan-claude-plugins.git"
}
```

When referenced via Git URL, Claude Code plugin system will:
1. Clone/fetch the repository
2. Look for `.claude-plugin/plugin.json` at the root
3. Load agents from `agents/` directory
4. Load commands from `commands/` directory

## Agent Prompt Format

Agent prompts use YAML frontmatter for configuration:

```markdown
---
name: agent-identifier
description: When to invoke this agent with examples
tools: Glob, Grep, Read, Bash, etc.
model: inherit|sonnet|opus|haiku
color: red|blue|green|etc.
---

# Agent system prompt goes here
```

**Critical Sections for Agent Prompts**:
- Clear invocation criteria with user/assistant dialogue examples
- Specific tool access requirements
- Detailed operating procedures and scanning phases
- Structured output format specifications
- Quality assurance checklists
