# Frontend Architecture and Workflow

Use this for frontend work after `project/agent-workflow-and-module-map`. The frontend is a ClojureScript SPA using React/Rumext components, Potok events, RxJS streams, okulary refs, SCSS modules, shared CLJC code from `common/`, and several JS/TS workspace packages.

## Stable namespace map

- `app.main.ui.*`: Rumext/React UI components for workspace, dashboard, viewer, settings, auth, nitrate, etc.
- `app.main.data.*`: Potok event handlers and side effects.
- `app.main.refs`: reactive refs/lenses over store and derived workspace data.
- `app.main.store`: Potok store and `emit!`.
- `app.plugins.*` and `app.plugins`: CLJS implementation of Plugin JS API proxies.
- `app.render_wasm.*`: frontend bridge to Rust/WASM renderer.
- `app.util.*`: DOM, HTTP, i18n, keyboard, codegen, and general frontend utilities.
- `frontend/packages/*` and `frontend/text-editor`: JS/TS workspace packages consumed by the app; read `frontend/ui-packages-text-editor-workflow` before changing them.
- Nitrate subscription/organization UI and flows live under `app.main.data.nitrate` and `app.main.ui.nitrate*`; backend/API behavior is in `backend/architecture-and-workflow`, and shared permission rules are in `common/src/app/common/types/nitrate_permissions.cljc`.

## Component and style conventions

Modern CLJS app components use `mf/defc` with `*` suffix, destructured props, and `[:> component* props]` calls. Prefer `mf/with-effect` / `mf/with-memo` macros where they improve clarity. Use `mf/deref` for refs from `app.main.refs`.

Styles are co-located SCSS modules. Use `app.main.style/stl` helpers in CLJS and design-system SCSS tokens/mixins. Avoid introducing legacy SCSS imports or high-specificity nested selectors when touching styles. For shared UI package/style-system boundaries, read `frontend/ui-conventions-and-style-system`.

## I18n and performance pitfalls

Do not call `(tr ...)` at namespace top level; call it during render or inside render-time memoization so runtime locale changes work. For static translated option lists, use render-time `mf/with-memo []` so labels respect the active locale while avoiding repeated work. Prefer `app.common.data.macros` helpers such as `dm/select-keys`, `dm/get-in`, and `dm/str` in performance-sensitive CLJS.

When UI logic grows inside a component, extract local pure helpers or move reusable logic to a helper namespace so it can be unit-tested. Prefer `app.util.dom` helpers over direct DOM access; add a helper there when no suitable one exists.

## High-value related memories

- Routing, app shell, websocket, and global errors: `frontend/routing-app-shell-subtleties`.
- Dashboard and viewer flows: `frontend/dashboard-viewer-subtleties`.
- Workspace token application/propagation: `frontend/workspace-token-subtleties` plus common token details in `common/tokens-schema-subtleties`.
- Workspace state, commits, persistence, refs: `frontend/workspace-state-persistence-subtleties`.
- Workspace transforms/modifier previews: `frontend/workspace-transform-subtleties`.
- Plugin JS API runtime: `frontend/plugin-api-runtime-subtleties`.
- Shared UI package, text editor, Storybook/package builds: `frontend/ui-packages-text-editor-workflow`.
- UI conventions and style-system boundaries: `frontend/ui-conventions-and-style-system`.
- Runtime inspection and navigation: `frontend/cljs-repl`.
- Source-edit compile/hot-reload diagnostics: `frontend/compile-diagnostics`.
- Runtime crash recovery: `frontend/handling-crashes`.
- Testing and live verification: `frontend/testing`.
- Real input reproduction: `frontend/playwright-gestures`.

## Areas without focused memories

These frontend areas currently have no dedicated Serena memory beyond this architecture entry and nearby source/tests: clipboard, drawing tools, boolean/path operations, interactions/prototyping, color/style asset management, grid-layout editing UI, comments UI, fonts UI, and many dashboard/settings subflows. Treat work there as less memory-covered and inspect source/tests more carefully.