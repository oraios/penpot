# Frontend UI Conventions and Style System

Use with `frontend/architecture-and-workflow` when changing app UI components, SCSS modules, shared UI primitives, or Storybook-facing UI behavior.

## CLJS app UI

- Main app components live under `frontend/src/app/main/ui*` and normally use Rumext `mf/defc` with a `*` suffix for component vars and `[:> component* props]` call sites.
- Co-located SCSS modules are preferred. Use `app.main.style/stl` helpers from CLJS and design-system SCSS tokens/mixins instead of legacy global selectors or high-specificity nesting.
- Translations must be resolved during render or render-time memoization, not at namespace load time. For static option lists, memoize inside render so locale changes still update labels.
- Keep expensive derived data in refs, memoized selectors, or pure helpers. In hot render paths, prefer existing `app.common.data.macros` helpers where local code already uses them.

## Shared React UI package

- `frontend/packages/ui` is the shared React/Vite package. It should remain framework-neutral relative to the CLJS app store; reusable primitives belong here only when they do not depend on Potok/Rumext app state.
- Package styles are emitted through the package build and copied into `frontend/resources/public/css/ui.css`; stale shared styles are often a build artifact issue.
- Storybook is the primary visual harness for shared UI/package behavior. Use `frontend/ui-packages-text-editor-workflow` for package build/test commands.

## Choosing a location

- Put editor/dashboard/viewer workflow logic in CLJS app namespaces close to the owning feature.
- Put reusable presentational React primitives in `frontend/packages/ui` when they can be consumed without Penpot app state.
- Put text editing internals in `frontend/text-editor` when the behavior belongs to the JS editor package; use `common/layout-text-token-subtleties` for shared text data-model behavior.

## Validation

- For CLJS app UI, use `frontend/testing`, `frontend/compile-diagnostics`, and live browser/REPL checks when behavior depends on store or canvas state.
- For shared UI package changes, run the package build plus Storybook/component tests when relevant.
- For text editor changes, run `frontend/text-editor` tests and refresh/copy WASM artifacts if render-wasm output is involved.