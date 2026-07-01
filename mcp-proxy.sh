#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configuration
# ------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/mcp-proxy.env"

# ------------------------------
# Start MCP proxy (SSE → stdio)
# ------------------------------
echo "Starting MCP proxy on port ${PROXY_PORT}..."
mcp-proxy \
    --named-server-config "$MCP_PROXY_CONFIG" \
    --allow-origin "*" \
    --port "$PROXY_PORT" \
    --stateless &
PROXY_PID=$!

# ------------------------------
# Cleanup function with status
# ------------------------------
cleanup() {
    echo ""
    echo "Shutting down MCP proxy..."

    if kill -0 $PROXY_PID 2>/dev/null; then
        kill $PROXY_PID
        wait $PROXY_PID 2>/dev/null && echo "✔ mcp-proxy exited with code $?" || true
    else
        echo "mcp-proxy already stopped."
    fi

    exit 0
}

trap cleanup INT TERM

# ------------------------------
# Show endpoint
# ------------------------------
echo ""
echo "✅ MCP SSE endpoint: http://localhost:${PROXY_PORT}/sse"
echo ""
echo "Press Ctrl+C to stop."

# Wait for the process (won't finish unless it crashes)
wait
