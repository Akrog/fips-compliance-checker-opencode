# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code plugin marketplace containing specialized agent plugins. Each plugin provides domain-specific capabilities through Claude Code's agent system.

## Repository Structure

```
claude-plugin-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata and plugin registry
└── {plugin-name}/                # Individual plugin directories
    ├── .claude-plugin/
    │   └── plugin.json           # Plugin metadata (name, version, author)
    ├── plugin.json               # (deprecated/legacy location)
    └── agents/
        └── {agent-name}.md       # Agent prompt definitions
```

## Plugin Architecture

### Marketplace Configuration
- **Location**: `.claude-plugin/marketplace.json`
- **Purpose**: Registers all plugins in the marketplace with metadata
- **Key fields**:
  - `name`: Marketplace identifier
  - `owner`: Marketplace maintainer information
  - `plugins[]`: Array of plugin references with source paths

### Plugin Structure
Each plugin is a self-contained directory containing:

1. **Plugin Metadata** (`.claude-plugin/plugin.json`)
   - Plugin name, version, description, and author
   - This is the canonical location (root `plugin.json` is legacy)

2. **Agent Definitions** (`agents/*.md`)
   - YAML frontmatter with agent configuration:
     - `name`: Agent identifier
     - `description`: When to invoke this agent (with examples)
     - `tools`: Available tools for the agent
     - `model`: Model selection (inherit, sonnet, opus, haiku)
     - `color`: Visual identifier
   - Markdown body: Complete agent system prompt

## Current Plugins

### red-hat-fips-compliance-checker
**Purpose**: FIPS 140-3 compliance auditing for containerized applications on RHEL 9+

**Agent**: `fips-compliance-checker`
- Scans source code, dependencies, and containers for FIPS compliance violations
- Identifies non-compliant cryptographic libraries and algorithms
- Provides detailed remediation guidance with code examples
- Generates compliance scores and automated fix scripts

**Key Capabilities**:
- Multi-language support (Python, Go, Rust, Java, C/C++)
- Dependency manifest analysis
- Container image scanning (check-payload integration)
- Algorithm compliance verification against FIPS 140-3 standards
- Structured JSON output with severity levels

## Adding New Plugins

1. Create plugin directory: `{plugin-name}/`
2. Add plugin metadata: `{plugin-name}/.claude-plugin/plugin.json`
3. Create agent definitions: `{plugin-name}/agents/{agent-name}.md`
4. Register in marketplace: Update `.claude-plugin/marketplace.json`

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

## Working with FIPS Compliance Checker

The FIPS agent follows a strict 6-phase scanning process:
1. Dependency Analysis
2. Source Code Analysis
3. Configuration Review
4. Container Analysis
5. Integration Points
6. Report Generation

**Output includes**:
- Compliance score (0-100) with breakdown by category
- JSON findings with severity, location, and remediation
- Automated remediation scripts
- Verification commands

**Severity Levels**:
- CRITICAL: Direct FIPS boundary violations
- HIGH: Security-critical operations using non-compliant algorithms
- MEDIUM: Approved algorithms without provider verification
- LOW: Configuration improvements or best practices
