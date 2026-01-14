#!/bin/bash
# RocketIndex wrapper - builds binary from local source if needed
# For local development marketplace

set -e

# Prefer system-installed rkt (Homebrew) over building
if command -v rkt &> /dev/null; then
    exec rkt "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RKT_BIN="$SCRIPT_DIR/rkt"
VERSION="0.1.0-beta.33"

# Path to RocketIndex source (relative to marketplace)
ROCKETINDEX_SRC="$SCRIPT_DIR/../../../../RocketIndex"

# Check if we need to build (missing or wrong version)
NEED_BUILD=false
if [ ! -x "$RKT_BIN" ]; then
    NEED_BUILD=true
else
    # Check installed version matches expected version
    INSTALLED_VERSION=$("$RKT_BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' || echo "unknown")
    if [ "$INSTALLED_VERSION" != "$VERSION" ]; then
        echo "Updating RocketIndex from $INSTALLED_VERSION to $VERSION..." >&2
        NEED_BUILD=true
    fi
fi

if [ "$NEED_BUILD" = true ]; then
    # Check if source directory exists
    if [ ! -d "$ROCKETINDEX_SRC" ]; then
        echo "Error: RocketIndex source not found at $ROCKETINDEX_SRC" >&2
        echo "Please ensure RocketIndex is checked out alongside the marketplace" >&2
        exit 1
    fi

    # Check if cargo is available
    if ! command -v cargo &> /dev/null; then
        echo "Error: cargo not found. Please install Rust from https://rustup.rs" >&2
        exit 1
    fi

    echo "Building RocketIndex $VERSION from source..." >&2

    # Build the binary
    (cd "$ROCKETINDEX_SRC" && cargo build --release --bin rkt --quiet) || {
        echo "Error: Failed to build RocketIndex" >&2
        exit 1
    }

    # Copy binary to plugin bin directory
    cp "$ROCKETINDEX_SRC/target/release/rkt" "$RKT_BIN"
    chmod +x "$RKT_BIN"

    echo "RocketIndex built and installed successfully" >&2
fi

# Execute rkt with all arguments
exec "$RKT_BIN" "$@"
