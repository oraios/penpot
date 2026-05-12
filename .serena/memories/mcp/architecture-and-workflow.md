# MCP Architecture and Workflow

`mcp/`: TypeScript/pnpm workspace for MCP integration. Contains AI-facing MCP server plus Penpot plugin bridge for design files.

## Layout and commands

- `packages/common`: shared request/response and task types.
- `packages/server`: MCP server, tool definitions, HTTP/SSE endpoints, WebSocket plugin connection, task correlation/timeouts.
- `packages/plugin`: Penpot MCP plugin that connects to the server over WebSocket and executes tasks inside the Penpot Plugin API context.
- `types-generator`: development tooling for API type data used by the server.
- From `mcp/`: setup `./scripts/setup`; build `pnpm run build`; bootstrap from source `pnpm run bootstrap`; start `pnpm run start`; multi-user variants `pnpm run build:multi-user`, `pnpm run start:multi-user`, `pnpm run bootstrap:multi-user`; format `pnpm run fmt` / `pnpm run fmt:check`; generate API type data `pnpm run build:types`.
- Default local endpoints: MCP HTTP `http://localhost:4401/mcp`, legacy SSE `http://localhost:4401/sse`, plugin manifest usually `http://localhost:4400/manifest.json`, plugin WebSocket port usually `4402`.
- The MCP plugin UI must stay open while using the server; closing it closes the design-file connection. If changing tool/task protocol, update server, plugin, and shared types.
- There is an older nested `.serena` project under `mcp/.serena`; do not assume its commands/paths are current without checking `mcp/package.json` and package READMEs.

## Tool availability

- Core tools are always registered: `execute_code`, `high_level_overview`, `penpot_api_info`, and `export_shape`.
- `import_image` requires filesystem-enabled local mode; remote/multi-user mode disables it.
- Dev tools require `PENPOT_MCP_DEVENV=true`: `cljs_repl`, `import_penpot_file`, `cljs_compiler_output`, and `clj_check_parentheses`.
- Multi-user mode or `PENPOT_MCP_REMOTE_MODE=true` forces remote mode.

## Server sessions and plugin bridge

- Streamable HTTP `/mcp` creates one `McpServer` per session and stores query `userToken` in session state. Later requests use that session token through AsyncLocalStorage.
- Legacy SSE stores user tokens per SSE session; `/messages` runs in that token context.
- Streamable sessions time out after about 60 minutes idle, checked about every 30 minutes.
- In multi-user mode, plugin WebSocket connections require `?userToken=...`; duplicate token connections are rejected. In single-user mode, tools require exactly one connected plugin instance.
- Task timeout defaults to about 30 seconds. Pending tasks are registered before sending and removed if the socket is not open; responses for unknown task IDs are logged and ignored.

## Tool execution semantics

- Base `Tool.execute` catches errors and returns a text result like `Tool execution failed: ...`; callers should not assume MCP protocol errors are thrown.
- Tool arguments are logged, with multiline strings indented. Avoid sending secrets through tool args.
- `execute_code` sends a plugin task and returns JSON for plugin task data (`result` plus captured `log`) when data exists; a code body with no return value reports success with no return value.

## Plugin-side execution

- The plugin keeps a persistent JS execution context while the plugin UI/session lives: `penpot`, `penpotUtils`, `storage`, and captured `console`. `storage` is not durable across plugin disconnects, UI close, or crashes.
- Code runs as the body of an async function, so `return` and top-level `await` inside that body work.
- The handler temporarily enables `penpot.flags.naturalChildOrdering` and `penpot.flags.throwValidationErrors`, restoring flags in `finally`. Missing flags indicate an incompatible Penpot version.
- Captured console stringifies object args with JSON, and `console.clear` intentionally no-ops.
- The plugin version check allows local Penpot version `0.0.0`; other mismatches are surfaced in the plugin UI.