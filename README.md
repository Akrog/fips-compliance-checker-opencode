# Claude Plugin Marketplace

A collection of specialized Claude Code plugins providing domain-specific capabilities through agent-based workflows.

## Adding This Marketplace

From within a Claude Code session, add this marketplace using the following slash command:

```
/plugin marketplace add https://gitlab.cee.redhat.com/gryan/gryan-claude-plugins.git
```

Verify the marketplace was added:

```
/plugin marketplace list
```

## Installing Plugins

### Interactive Installation (Recommended)

Browse and install plugins interactively:

```
/plugin
```

### Direct Installation

Install a specific plugin from this marketplace:

```
/plugin install <plugin-name>@<marketplace-name>
```

Example:

```
/plugin install fips-compliance-checker@gryan-claude-plugins
```

## Available Plugins

### fips-compliance-checker

FIPS 140-3 compliance auditing for containerized applications on RHEL 9+.

**Usage:**
- Natural language: "Check if my app is FIPS compliant"
- Slash command: `/fips-scan` or `/fips-scan quay.io/myorg/myapp:v1.2.3`

See [fips-compliance-checker/README.md](./fips-compliance-checker/README.md) for detailed documentation.

## Verification

View installed plugins and their status:

```
/plugin
```

## Documentation

For detailed plugin documentation and development information, see [CLAUDE.md](./CLAUDE.md).
