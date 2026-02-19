# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Claude Code plugin marketplace** repository. It packages and distributes MCP (Model Context Protocol) server plugins for the Claude Code IDE.

## Repository Structure

```
.claude-plugin/
  marketplace.json          # Marketplace definition (version registry)
plugins/
  rocketindex/              # Semantic code navigation plugin (local)
    .claude-plugin/plugin.json
    bin/rkt-wrapper.sh      # Downloads rkt binary on first use
    hooks/                  # PreToolUse hook for auto-injecting project_root
```

The **manifest** plugin is sourced externally from `manifestdocs/manifest-plugin`.

## Plugin Commands

```bash
# User installation (in Claude Code)
/plugin marketplace add manifestdocs/claude-plugins
/plugin install rocketindex@manifest-plugins
/plugin install manifest@manifest-plugins
```

## Versioning

For local plugins (rocketindex), version numbers must be updated in TWO places:
1. `.claude-plugin/marketplace.json` - marketplace registry
2. `plugins/<name>/.claude-plugin/plugin.json` - plugin metadata

For external plugins (manifest), the version in marketplace.json should match the version in the external repo's `.claude-plugin/plugin.json`.

## Architecture

### MCP Server Integration
Each plugin runs as an MCP server:
- **rocketindex**: `rkt-wrapper.sh serve` starts the RocketIndex server (stdin/stdout JSON)
- **manifest**: HTTP-based MCP server at `http://localhost:17010/mcp`

### PreToolUse Hook (rocketindex)
The hook in `plugins/rocketindex/hooks/` automatically injects Claude's working directory as `project_root` before any RocketIndex tool executes. The hook:
- Matches tools via `mcp__*rocket*` pattern
- Respects explicitly-specified `project_root` (doesn't override)
- Special-cases `describe_project` (uses `path` instead)

### Binary Distribution (rocketindex)
The wrapper script handles platform detection and downloads binaries from GitHub releases:
- Supports: macOS (arm64/x86_64), Linux (x86_64/aarch64)
- Binaries are ~30MB, downloaded on first use
- Version mismatch triggers automatic update

## Source Repositories

- **RocketIndex**: https://github.com/manifestdocs/rocket-index (Rust)
- **Manifest**: https://github.com/manifestdocs/manifest (Rust)
- **Manifest Plugin**: https://github.com/manifestdocs/manifest-plugin (Skills + MCP config)
