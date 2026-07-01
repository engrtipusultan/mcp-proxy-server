# MCP Proxy Server

Aggregates multiple MCP servers behind a single SSE endpoint using [`mcp-proxy`](https://github.com/anthropics/mcp-proxy).

**Why:** Some web UI clients (e.g., llama.cpp UI) only support `/sse` or `/mcp` endpoints — they cannot spawn stdio subprocesses. This proxy wraps stdio-based MCP servers behind `http://localhost:8001/sse`, making them accessible to such clients.

## Usage

```bash
./mcp-proxy.sh
```

All MCP servers are available via SSE at `http://localhost:8001/sse`.

### Configuration

Edit `mcp-proxy.env` to change the port or config path:

```bash
PROXY_PORT=8001
MCP_PROXY_CONFIG=/path/to/mcp-proxy.json
```

### Available servers in given json config file

| Server | Command | Purpose |
|--------|---------|---------|
| `time` | `mcp-server-time --local-timezone=Asia/Karachi` | Current time and date |
| `fetch` | `mcp-server-fetch` | Web page content fetching |
| `ddg-search` | `duckduckgo-mcp-server` | DuckDuckGo web search |
| `browsermcp` | `npx @browsermcp/mcp@latest` | Headless browser automation |
| `tolaria` | `node ~/.local/share/tolaria/mcp-server/index.js` | Markdown vault/note management |
| `trafilatura` | `node ~/Development/trafilatura/build/index.js` | Web content extraction |
| `drawio` | `node ~/Development/GH/drawio-mcp/mcp-tool-server/src/index.js` | Open diagrams in browser |
| `drawio-app` | `node ~/Development/GH/drawio-mcp/mcp-app-server/src/index.js --stdio` | Inline diagrams + shape search |
| `dynamic-prompts` | `npx tsx ~/Development/mcp-prompts-server/server.ts` | Dynamic prompt templates |

## Example

![MCP Servers available in the llama.cpp server](screenshots/Screenshot%20from%202026-07-01%2014-21-09.png)

## License

Apache 2.0

---

# Draw.io Integration

The draw.io MCP servers let you create and edit diagrams from chat. Two servers are available:

| Server | Tools | How diagrams are viewed |
|--------|-------|------------------------|
| `drawio` | `open_drawio_xml`, `open_drawio_csv`, `open_drawio_mermaid` | Opens in the browser via a locally hosted draw.io web editor |
| `drawio-app` | `create_diagram`, `search_shapes` | Renders inline in chat + searches 10,000+ shapes |

### Prerequisites

The `drawio` tool server opens diagrams in the browser. It needs the draw.io Warava UI running locally:

```bash
./start-drawio-server.sh
```

This serves the draw.io web editor at `http://localhost:7001`.

### Configuration

Edit `drawio.env` to change the web editor port or webapp path:

```bash
DRAWIO_WEB_PORT=7001
DRAWIO_WEB_DIR=/path/to/drawio/src/main/webapp
```

### How the drawio-mcp components connect

```
              draw.io web editor (http-server, port 7001)
                    ↑ 
              opens diagrams in browser
              drawio     (tool server) --→ mcp-proxy --→ SSE client
              drawio-app (app server)  --→ mcp-proxy --→ SSE client (inline rendering)
```

Both draw.io MCP servers are registered in `mcp-proxy.json` and served through the proxy alongside all other servers. The `drawio-app` entry uses `--stdio` to communicate over stdio (required by `mcp-proxy`).
