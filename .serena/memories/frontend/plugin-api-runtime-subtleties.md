# Frontend Plugin API Runtime Subtleties

Use when changing the in-app Plugin API implementation under `frontend/src/app/plugins*`, or when debugging differences between TypeScript Plugin API declarations and real runtime behavior.

## Type declarations vs runtime

- `plugins/libs/plugin-types/index.d.ts` contains TypeScript declarations only. Runtime objects are CLJS proxies built under `frontend/src/app/plugins/*.cljs` with `obj/reify`.
- `shape.cljs` builds shape proxies with hidden ids and per-property CLJS implementations. `library.cljs` builds library proxies such as `LibraryComponentProxy`.
- `shape.cljs`, `library.cljs`, and related namespaces break circular dependencies with mutable nil vars patched from `app.plugins` at load time. If a proxy constructor appears nil, check the patching path in `frontend/src/app/plugins.cljs`.
- Useful domain namespaces: `app.common.types.component` for component predicates, `app.common.types.container` for tree/head/root operations, and `app.common.types.file` for resolving components/ref shapes.

## Runtime initialization and permissions

- The frontend initializes `@penpot/plugins-runtime` only after `features/initialize` and only when feature `plugins/runtime` is active. It also installs the runtime `isPluginError` predicate into frontend error handling.
- Manifest parsing expands write permissions to read permissions (`content:write` => `content:read`, etc.). Permission checks also allow the all-zero plugin id and the hard-coded MCP plugin id.
- Manifest URL origin differs by manifest version: v1 clears the path; v2 joins `.` to the plugin URL. Existing plugin ids are reused by matching manifest name and host.
- The MCP plugin id is defined in `app.plugins.register` to avoid a circular dependency with workspace MCP code.

## Proxy behavior

- Public Plugin API objects are lightweight handles, not durable snapshots. Most getters locate fresh state from `app.main.store/state` using hidden `$id`, `$file`, `$page`, etc.
- `not-valid` logs by default but throws when the plugin flag `throwValidationErrors` is enabled. The MCP execute-code handler deliberately enables that flag while running code.
- `naturalChildOrdering` and `throwValidationErrors` are stored per plugin under `[:plugins :flags plugin-id ...]`; changing default behavior affects automation and MCP diagnostics.
- Plugin data is stored under keyword namespaces: private data uses `(keyword "plugin" plugin-id)`, shared data uses `(keyword "shared" namespace)`.

## Events and history

- Plugin listeners are watches on the global store and callbacks are debounced about 10ms. Callback exceptions are caught and logged so plugin code does not crash the app.
- `selectionchange` callbacks receive arrays of shape id strings, while `filechange`, `pagechange`, and `shapechange` return proxies.
- `contentsave` fires only when persistence status transitions to `:saved`; it calls the callback with no value.
- Plugin history `undoBlockBegin` creates a workspace undo transaction with a JS `Symbol`; `undoBlockFinish` commits that symbol. Missing finish eventually relies on the workspace transaction timeout.