# Project Agent Workflow and Module Map

Start here for Penpot memory routing: repo-level workflow, module map, changelog routing, dependency cautions.

## Workflow

- Identify the affected module(s), then follow the module map to the relevant subsection introductory memory instead of loading unrelated context.
- Commit only when explicitly asked. Commit/PR format + changelog: `mem:workflow/creating-commits`, `mem:workflow/creating-prs`.
- Docker/devenv, CI, root tooling, cross-module validation: `mem:project/dev-ci-environment-workflow`.
- GitHub collaborator/PR metadata: `mem:workflow/github-queries`.
- Memory edits/stale refs/duplication cleanup: `mem:project/memory-maintenance`.

## Stable module map

- `frontend/`: ClojureScript + SCSS SPA/design editor. Start with `mem:frontend/core`.
- `backend/`: JVM Clojure HTTP/RPC server with PostgreSQL, Redis, storage, mail, and workers. Start with `mem:backend/core`.
- `common/`: shared CLJC data types, geometry, schemas, file/change logic, and utilities. Start with `mem:common/core`.
- `render-wasm/`: Rust -> WebAssembly Skia renderer consumed by frontend. Start with `mem:render-wasm/core`.
- `exporter/`: ClojureScript/Node headless Playwright SVG/PDF export. Start with `mem:exporter/core`.
- `mcp/`: TypeScript Model Context Protocol integration. Start with `mem:mcp/core`.
- `plugins/`: TypeScript plugin runtime/examples and Plugin API types. Start with `mem:plugins/core`.
- `library/`: design library workflows. Start with `mem:library/core`.
- `docs/`: documentation site. Start with `mem:workflow/docs`.

## Low-centrality paths

- `docker/` and root tooling are covered by `mem:project/dev-ci-environment-workflow`; root scripts such as `scripts/lint`, `scripts/check-fmt`, and `scripts/fmt` are wrappers around module-local checks.
- `experiments/` contains standalone experimental HTML/JS/scripts; treat it as non-core unless the user explicitly asks about it.
- `sample_media/` contains sample image/icon media and config used as fixtures/demo material; do not infer app behavior from it.
- `.opencode/`, `opencode.json`, and agent/tooling config are project-local AI/dev tooling, not Penpot runtime code.

## Dependency graph

`frontend -> common`, `backend -> common`, `exporter -> common`, and `frontend -> render-wasm`. Changes in `common` can affect frontend, backend, exporter, file migrations, and design-library behavior; validate across consumers when semantics change.