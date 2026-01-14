# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Claude Code plugin marketplace** repository. It packages and distributes two MCP (Model Context Protocol) server plugins for the Claude Code IDE. The actual source code for these tools lives in separate repositories - this repo handles distribution via wrapper scripts that download binaries on first use.

## Repository Structure

```
.claude-plugin/
  marketplace.json          # Marketplace definition (version registry)
plugins/
  rocketindex/              # Semantic code navigation plugin
    .claude-plugin/plugin.json
    bin/rkt-wrapper.sh      # Downloads rkt binary on first use
    hooks/                  # PreToolUse hook for auto-injecting project_root
  manifest/                 # Feature documentation plugin
    .claude-plugin/plugin.json
    bin/mfst-wrapper.sh     # Downloads mfst binary on first use
```

## Plugin Commands

```bash
# User installation (in Claude Code)
/plugin marketplace add rocket-tycoon/claude-plugins
/plugin install rocketindex
/plugin install manifest
```

## Versioning

**Critical**: Version numbers must be updated in TWO places when releasing:
1. `.claude-plugin/marketplace.json` - marketplace registry
2. `plugins/<name>/.claude-plugin/plugin.json` - plugin metadata

The wrapper scripts (`rkt-wrapper.sh`, `mfst-wrapper.sh`) also contain hardcoded version strings that determine which binary version to download.

## Architecture

### MCP Server Integration
Each plugin runs as an MCP server communicating via stdin/stdout JSON:
- **rocketindex**: `rkt-wrapper.sh serve` starts the RocketIndex server
- **manifest**: `mfst-wrapper.sh mcp` starts the Manifest server

### PreToolUse Hook (rocketindex)
The hook in `plugins/rocketindex/hooks/` automatically injects Claude's working directory as `project_root` before any RocketIndex tool executes. This bridges Claude Code's context with the MCP server. The hook:
- Matches tools via `mcp__*rocket*` pattern
- Respects explicitly-specified `project_root` (doesn't override)
- Special-cases `describe_project` (uses `path` instead)

### Binary Distribution
Wrapper scripts handle platform detection and download binaries from GitHub releases:
- Supports: macOS (arm64/x86_64), Linux (x86_64/aarch64)
- Binaries are ~30MB, downloaded on first use
- Version mismatch triggers automatic update

## Source Repositories

- **RocketIndex**: https://github.com/rocket-tycoon/rocket-index (Rust)
- **Manifest**: https://github.com/rocket-tycoon/manifest (Rust)
