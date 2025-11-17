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
    ├── README.md                 # Plugin documentation (optional but recommended)
    ├── agents/
    │   └── {agent-name}.md       # Agent prompt definitions
    └── commands/                 # Slash commands (optional)
        └── {command-name}.md     # Command definitions
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

1. **Plugin Metadata** (`.claude-plugin/plugin.json`) - *Required*
   - Plugin name, version, description, and author
   - This is the canonical location (root `plugin.json` is legacy)

2. **Agent Definitions** (`agents/*.md`) - *Required*
   - YAML frontmatter with agent configuration:
     - `name`: Agent identifier
     - `description`: When to invoke this agent (with examples)
     - `tools`: Available tools for the agent
     - `model`: Model selection (inherit, sonnet, opus, haiku)
     - `color`: Visual identifier
   - Markdown body: Complete agent system prompt

3. **Slash Commands** (`commands/*.md`) - *Optional*
   - Provides explicit command-based invocation
   - Complements agent auto-selection with user-initiated triggers
   - YAML frontmatter with command description
   - Markdown body: Instructions for Claude when command is invoked
   - Can accept arguments: `{?arg_name:description}`

4. **Plugin Documentation** (`README.md`) - *Optional but recommended*
   - Installation instructions
   - Usage examples (both natural language and slash commands)
   - Scan coverage and capabilities
   - Output format descriptions
   - Reference links

## Current Plugins

### fips-compliance-checker
**Purpose**: FIPS 140-3 compliance auditing for containerized applications on RHEL 9+

**Agent**: `fips-compliance-checker:fips-compliance-checker`
- Scans source code, dependencies, and containers for FIPS compliance violations
- Identifies non-compliant cryptographic libraries and algorithms
- Provides detailed remediation guidance with code examples
- Generates compliance scores and automated fix scripts

**Slash Command**: `/fips-compliance-checker:fips-scan [image]`
- Explicit invocation for FIPS compliance scanning
- Optional container image argument for targeted analysis
- Must use fully-qualified form (currently required by Claude Code CLI)

**Key Capabilities**:
- Multi-language support (Python, Go, Rust, Java, C/C++)
- Dependency manifest analysis
- Container image scanning (check-payload integration)
- Algorithm compliance verification against FIPS 140-3 standards
- Structured JSON output with severity levels

## Adding New Plugins

### Required Steps
1. Create plugin directory: `{plugin-name}/`
2. Add plugin metadata: `{plugin-name}/.claude-plugin/plugin.json`
3. Create agent definitions: `{plugin-name}/agents/{agent-name}.md`
4. Register in marketplace: Update `.claude-plugin/marketplace.json`

### Optional but Recommended Steps
5. Add plugin documentation: `{plugin-name}/README.md`
6. Create slash commands: `{plugin-name}/commands/{command-name}.md`
7. Update main README with plugin description and usage

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

### Agent Description Best Practices

The `description` field is critical for agent auto-selection. Follow these guidelines:

**Use Strong Directive Language**:
- Start with "MUST BE USED PROACTIVELY" to encourage automatic invocation
- This signals to Claude that the agent should be aggressively selected when context matches

**Include Concrete Examples**:
```markdown
<example>
Context: [Situation description]
user: "[Example user query]"
assistant: "[How Claude should respond and invoke the agent]"
<agent invocation with Task tool>
</example>
```

**List Proactive Triggers**:
```markdown
MUST BE USED PROACTIVELY when:
- User mentions [specific keywords or concepts]
- User discusses [relevant domain topics]
- User is working with [specific technologies or patterns]
```

**Example Description Structure**:
```markdown
description: MUST BE USED PROACTIVELY when you need to [primary purpose].

<example>
Context: [Scenario 1]
user: "[Example query 1]"
assistant: "[Response invoking agent]"
</example>

<example>
Context: [Scenario 2]
user: "[Example query 2]"
assistant: "[Response invoking agent]"
</example>

MUST BE USED PROACTIVELY when:
- [Trigger condition 1]
- [Trigger condition 2]
- [Trigger condition 3]
```

This approach significantly improves agent auto-selection compared to softer language like "Use this agent when..." or "Proactively suggest..."

## Slash Commands

Slash commands provide explicit, user-initiated invocation of plugin functionality. They complement agent auto-selection by giving users a direct way to trigger specific behaviors.

### Command File Format

Commands are Markdown files in the `commands/` directory with frontmatter:

```markdown
---
description: Brief description shown in command menu
---

Detailed instructions for Claude when this command is invoked.

{?arg_name:Argument description (optional)}

Use the Task tool with subagent_type="{agent-name}" to perform [action].
```

### Command Invocation

**Fully-qualified form** (currently required):
```
/plugin-name:command-name
/plugin-name:command-name arg1 arg2
```

Note: Claude Code CLI currently requires the fully-qualified format. Short form `/command-name` is not currently supported, though the syntax may be added in future versions.

### Argument Syntax

Optional arguments use `{?arg_name:description}`:
```markdown
{?image:Container image reference (optional, e.g., quay.io/myorg/myapp:latest)}

Scan {?image:the container image `{image}`:the current project} for issues.
```

This creates conditional text:
- With argument: "Scan the container image `quay.io/myorg/myapp:latest` for issues."
- Without argument: "Scan the current project for issues."

### When to Add Slash Commands

**Add commands when**:
- Users need explicit, guaranteed invocation (not relying on auto-selection)
- The plugin has a clear "primary action" that benefits from shortcut access
- Arguments make the interaction more efficient (e.g., container images, file paths)
- Power users would benefit from command-line style interaction

**Skip commands when**:
- Natural language interaction is sufficient
- The agent auto-selects reliably
- Adding a command would create unnecessary complexity

### Commands vs Agents

- **Agents**: Auto-select based on context, handle complex workflows, provide deep expertise
- **Commands**: User-initiated, explicit invocation, quick shortcuts, argument-based input
- **Best Practice**: Use both - commands for explicit access, agents for smart auto-selection

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
