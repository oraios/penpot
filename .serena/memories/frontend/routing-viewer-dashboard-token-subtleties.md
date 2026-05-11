# Frontend Routing, Viewer, Dashboard, and Token Subtleties

Use with `frontend/architecture-and-workflow` when changing app startup/routing, dashboard/viewer data flows, websocket handling, global error behavior, or token application/propagation.

## Router, app shell, and errors

- Routing uses browser-history hash tokens, but `on-navigate` rejects navigation if the current origin/path does not match `cf/public-uri`.
- Route params are split into `:path` and `:query`; duplicate query params can become vectors, so use `rt/get-query-param` when a scalar is required.
- Unknown/empty routes trigger an extra `get-profile`/`get-teams` check before redirecting. This avoids invitation and root-route race conditions.
- The root app renders an exception page from `:exception` state before the normal error boundary. `rt/navigated` clears `:exception`.
- Frontend error handling treats stale cross-build JS chunk failures specially: messages containing `$cljs$cst$` or `$cljs$core$I` plus undefined/null/not-a-function signatures trigger throttled reload.
- Plugin-originated uncaught errors are identified through the plugin runtime hook and logged rather than turning into the global exception page.

## Store and websocket

- `app.main.store/emit!` always returns nil; use streams/events for completion, not the return value.
- Store `last-events` is a filtered rolling buffer useful for error reports and REPL diagnosis.
- Websocket initialization uses `cf/public-uri` joined with `ws/notifications`, converting `http/https` to `ws/wss`, and includes the current `session-id` as query param.
- Reinitializing or finalizing websocket stops the previous receive stream. Incoming websocket payloads become Potok data events under `app.main.data.websocket/message`.

## Dashboard

- Dashboard initialization fetches projects and fonts for the team, then listens to websocket messages only for global topic `uuid/zero` or the current profile id.
- Project fetch replaces each project map completely instead of merging, so fields such as `deleted-at` can disappear cleanly.
- Dashboard file/project mutations are often optimistic local updates with fire-and-forget RPC watchers. Bulk permanent delete/restore paths use SSE progress and progress notifications.
- File creation/duplication strips file `:data` before putting file summaries into dashboard state.

## Viewer

- Viewer initialization sets `:current-file-id`, `:current-share-id`, and `:viewer-local`, then fetches the view-only bundle. Comment threads are fetched only for logged-in users.
- Viewer bundle fetch sends the full supported feature set because anonymous shared viewers may not know team-enabled features.
- View-only bundles can contain pointer values in `:pages-index` and file data. Viewer resolves those fragments with `:get-file-fragment` before storing the bundle.
- `bundle-fetched` indexes pages and precomputes viewer frames/all-frames, stores libraries/users/thumbnails/permissions under `:viewer`, then navigates to frame id, query index, or auto-selected frame.
- Viewer zoom and interaction mode changes update both `:viewer-local` and the `:viewer` route query params.

## Tokens in workspace

- Workspace token refs intentionally hide the internal hidden theme from theme trees/lists and expose active tokens through `get-tokens-in-active-sets`.
- Token application refuses to run while a text shape is in text-editing mode and shows a warning instead.
- Applying a token writes token names into shape `:applied-tokens`, resolves active tokens through Style Dictionary or `tokenscript` depending on feature flags, updates concrete shape attrs, and wraps the operation in an undo transaction.
- Applying composite typography removes atomic typography token attrs and applying atomic typography removes the composite typography token attr.
- Spacing tokens have a special split path: layout containers receive gap/padding updates, while immediate children of layouts receive margin updates.
- Token propagation resolves active tokens, buffers many `update-shapes` commits, walks the current page first then the remaining pages, clears affected frame/component thumbnails, and drops `:position-data` for text shapes on non-current pages so it can be regenerated.