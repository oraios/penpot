# Frontend Testing and Live Verification

Use with `frontend/architecture-and-workflow` for frontend validation. Frontend code is ClojureScript + React/Rumext + RxJS/Potok state, with SCSS modules and shared CLJC dependencies from `common/`.

## Unit Tests

Frontend unit tests live under `frontend/test/frontend_tests/` and use `cljs.test`. They should be deterministic, avoid DOM/UI integration where possible, and mock side effects such as RPC, storage, timers, or network access.

From `frontend/`:
- Full unit test run: `pnpm run test`.
- Focused unit tests: edit `test/frontend_tests/runner.cljs` to narrow the suite, then run `pnpm run test`.
- Build test target only: `pnpm run build:test`.
- Watch tests: `pnpm run watch:test`.

Do not add, modify, or run Playwright integration tests under `frontend/playwright` unless explicitly asked. When explicitly asked, use `pnpm run test:e2e` or `pnpm run test:e2e --grep "pattern"` from `frontend/`; ensure dependencies are installed through `./scripts/setup` if the environment is not prepared.

## Lint and Format

From `frontend/`:
- CLJ/CLJS lint: `pnpm run lint:clj`.
- JS lint currently no-ops via `pnpm run lint:js`.
- SCSS lint: `pnpm run lint:scss`.
- Format checks: `pnpm run check-fmt:clj`, `pnpm run check-fmt:js`, `pnpm run check-fmt:scss`.
- Format fix: `pnpm run fmt`, or targeted `fmt:clj` / `fmt:js` / `fmt:scss`.

## Live Browser Verification

Because CLJC compiles to both JVM and CLJS, JVM/common tests can miss frontend-only state caused by browser runtime, WASM modifier math, or real pointer events. Use `frontend/cljs-repl` to inspect live app state and `frontend/playwright-gestures` when real input is needed.

After CLJ/CLJC/CLJS edits, use `frontend/compile-diagnostics` if the app does not hot-reload or behavior appears stale. If the live workspace behaves oddly after automation and the compiler is healthy, read `frontend/handling-crashes` and check `(some? (:exception @app.main.store/state))`.

## CLJC Hot Reload

When the frontend shadow-cljs watch process is running, edits to CLJC files in `common/` are automatically recompiled and pushed to the browser. No page reload is normally required. If hot reload fails, follow `frontend/compile-diagnostics` before restarting.