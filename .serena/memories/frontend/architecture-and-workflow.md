# Frontend Architecture and Workflow

Use this as the frontend introductory memory. The frontend is a ClojureScript SPA using React/Rumext components, Potok events, RxJS streams, okulary refs, SCSS modules, shared CLJC code from `common/`, and several JS/TS workspace packages.

## Stable namespace map

- `app.main.ui.*`: Rumext/React UI components for workspace, dashboard, viewer, settings, auth, nitrate, etc.
- `app.main.data.*`: Potok event handlers and side effects.
- `app.main.refs`: reactive refs/lenses over store and derived workspace data.
- `app.main.store`: Potok store and `emit!`.
- `app.plugins.*` and `app.plugins`: CLJS implementation of Plugin JS API proxies.
- `app.render_wasm.*`: frontend bridge to Rust/WASM renderer.
- `app.util.*`: DOM, HTTP, i18n, keyboard, codegen, and general frontend utilities.
- `frontend/packages/*` and `frontend/text-editor`: JS/TS workspace packages consumed by the app; read `frontend/ui-packages-text-editor-workflow` before changing them.
- Nitrate subscription/organization UI and flows live under `app.main.data.nitrate` and `app.main.ui.nitrate*`; backend/API behavior is covered by backend memories, and shared permission rules are in `common/src/app/common/types/nitrate_permissions.cljc`.

## Focused memory routing

UI and packages:
- App UI components, SCSS modules, style-system boundaries, accessibility, i18n, and render performance: `frontend/ui-conventions-and-style-system`.
- JS/TS packages, shared UI package, text editor, Storybook, and package builds: `frontend/ui-packages-text-editor-workflow`.

Workspace behavior:
- Workspace state, commits, persistence, undo, repo calls, and refs: `frontend/workspace-state-persistence-subtleties`.
- Workspace transforms, modifier previews, WASM modifier integration, and transform commits: `frontend/workspace-transform-subtleties`.
- Workspace token application/propagation: `frontend/workspace-token-subtleties`; for shared token data/schema behavior also read `common/tokens-schema-subtleties`.

App shell and product flows:
- Routing, root app shell, websocket, and global errors: `frontend/routing-app-shell-subtleties`.
- Dashboard and viewer flows: `frontend/dashboard-viewer-subtleties`.
- Plugin JS API runtime inside the frontend app: `frontend/plugin-api-runtime-subtleties`.

Diagnostics and validation:
- Runtime inspection and navigation: `frontend/cljs-repl`.
- Source-edit compile/hot-reload diagnostics: `frontend/compile-diagnostics`.
- Runtime crash recovery: `frontend/handling-crashes`.
- Tests, lint, format, and live verification: `frontend/testing`.
- Real pointer/keyboard gesture reproduction: `frontend/playwright-gestures`.

## Areas without focused memories

These frontend areas currently have no dedicated Serena memory beyond this architecture entry and nearby source/tests: clipboard, drawing tools, boolean/path operations, interactions/prototyping, color/style asset management, grid-layout editing UI, comments UI, fonts UI, and many dashboard/settings subflows. Treat work there as less memory-covered and inspect source/tests more carefully.