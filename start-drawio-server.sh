#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configuration
# ------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/drawio.env"

# ------------------------------
# Start draw.io web editor
# ------------------------------
echo "Starting draw.io web editor on port ${DRAWIO_WEB_PORT}..."
cd "$DRAWIO_WEB_DIR"
npx http-server -p "$DRAWIO_WEB_PORT" --cors -c-1 &
WEB_PID=$!
sleep 2
if ! kill -0 $WEB_PID 2>/dev/null; then
    echo "ERROR: http-server failed to start."
    exit 1
fi

# ------------------------------
# Cleanup function with status
# ------------------------------
cleanup() {
    echo ""
    echo "Shutting down draw.io web server..."

    if kill -0 $WEB_PID 2>/dev/null; then
        kill $WEB_PID
        wait $WEB_PID 2>/dev/null && echo "✔ draw.io web server exited with code $?" || true
    else
        echo "draw.io web server already stopped."
    fi

    exit 0
}

trap cleanup INT TERM

# ------------------------------
# Show endpoint
# ------------------------------
echo ""
echo "✅ draw.io web editor: http://localhost:${DRAWIO_WEB_PORT}"
echo ""
echo "Press Ctrl+C to stop."

# Wait for the process (won't finish unless it crashes)
wait
