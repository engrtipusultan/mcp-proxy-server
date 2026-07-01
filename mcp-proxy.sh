#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configuration
# ------------------------------
DRAWIO_WEBAPP_DIR="/home/tipu/Development/GH/drawio/src/main/webapp"
DRAWIO_PORT=7001
PROXY_CONFIG="/home/tipu/Applications/llamacpp/mcp-proxy.json"
PROXY_PORT=8001

# ------------------------------
# Start draw.io web editor
# ------------------------------
echo "Starting draw.io web editor on port ${DRAWIO_PORT}..."
cd "$DRAWIO_WEBAPP_DIR"
npx http-server -p "$DRAWIO_PORT" --cors -c-1 &
WEB_PID=$!
sleep 2
if ! kill -0 $WEB_PID 2>/dev/null; then
    echo "ERROR: http-server failed to start."
    exit 1
fi

# ------------------------------
# Start MCP proxy (SSE → stdio)
# ------------------------------
echo "Starting MCP proxy on port ${PROXY_PORT}..."
mcp-proxy \
    --named-server-config "$PROXY_CONFIG" \
    --allow-origin "*" \
    --port "$PROXY_PORT" \
    --stateless &
PROXY_PID=$!

# ------------------------------
# Cleanup function with status
# ------------------------------
cleanup() {
    echo ""
    echo "Shutting down..."

    # Kill web server and capture exit code if still alive
    if kill -0 $WEB_PID 2>/dev/null; then
        kill $WEB_PID
        wait $WEB_PID 2>/dev/null && echo "✔ http-server exited with code $?" || true
    else
        echo "http-server already stopped."
    fi

    # Kill mcp-proxy and capture exit code
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
# Show endpoints
# ------------------------------
echo ""
echo "✅ Local draw.io: http://localhost:${DRAWIO_PORT}"
echo "✅ MCP SSE endpoint: http://localhost:${PROXY_PORT}/sse"
echo "✅ Diagram URLs will use http://localhost:${DRAWIO_PORT}"
echo ""
echo "Press Ctrl+C to stop both services."

# Wait for either process to finish (they won’t unless they crash)
wait