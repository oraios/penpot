# Frontend Architecture and Workflow

Use this for frontend work after `project/agent-workflow-and-module-map`. The frontend is a ClojureScript SPA using React/Rumext components, Potok events, RxJS streams, okulary refs, SCSS modules, and shared CLJC code from `common/`.

## Stable namespace map

- `app.main.ui.*`: Rumext/React UI components for workspace, dashboard, viewer, etc.
- `app.main.data.*`: Potok event handlers and side effects.
- `app.main.refs`: reactive refs/lenses over store and derived workspace data.
- `app.main.store`: Potok store and `emit!`.
- `app.plugins.*` and `app.plugins`: CLJS implementation of Plugin JS API proxies.
- `app.render_wasm.*`: frontend bridge to Rust/WASM renderer.
- `app.util.*`: DOM, HTTP, i18n, keyboard, and general frontend utilities.

## Component and style conventions

Modern components use `mf/defc` with `*` suffix, destructured props, and `[:> component* props]` calls. Prefer `mf/with-effect` / `mf/with-memo` macros where they improve clarity. Use `mf/deref` for refs from `app.main.refs`.

Styles are co-located SCSS modules. Use `app.main.style/stl` helpers in CLJS and design-system SCSS tokens/mixins. Avoid introducing legacy SCSS imports or high-specificity nested selectors when touching styles.

## I18n and performance pitfalls

Do not call `(tr ...)` at namespace top level; call it during render or inside render-time memoization so runtime locale changes work. For static translated option lists, use render-time `mf/with-memo []` so labels respect the active locale while avoiding repeated work. Prefer `app.common.data.macros` helpers such as `dm/select-keys`, `dm/get-in`, and `dm/str` in performance-sensitive CLJS.

When UI logic grows inside a component, extract local pure helpers or move reusable logic to a helper namespace so it can be unit-tested. Prefer `app.util.dom` helpers over direct DOM access; add a helper there when no suitable one exists.

## High-value related memories

- Routing, app shell, dashboard/viewer flows, websocket, token application: `frontend/routing-viewer-dashboard-token-subtleties`.
- Workspace state, commits, persistence, refs: `frontend/workspace-state-persistence-subtleties`.
- Workspace transforms/modifier previews: `frontend/workspace-transform-subtleties`.
- Plugin JS API runtime: `frontend/plugin-api-runtime-subtleties`.
- Runtime inspection and navigation: `frontend/cljs-repl`.
- Source-edit compile/hot-reload diagnostics: `frontend/compile-diagnostics`.
- Runtime crash recovery: `frontend/handling-crashes`.
- Testing and live verification: `frontend/testing`.
- Real input reproduction: `frontend/playwright-gestures`.