# Project Agent Workflow and Module Map

Use this when starting a Penpot task from the memory list. It consolidates repository-level agent guidance and routes you to subsection introductory memories.

## Working flow

- Identify the affected module(s), then follow the module map to the relevant subsection introductory memory instead of loading unrelated context.
- Commit only when explicitly asked. For commit/PR format and changelog expectations, read `workflow/creating-commits` and `workflow/creating-prs`.
- For Docker/devenv, CI workflows, root tooling, or cross-module validation, read `project/dev-ci-environment-workflow`.
- For GitHub collaborator/PR metadata queries, read `workflow/github-queries`.

## Stable module map

- `frontend/`: ClojureScript + SCSS SPA/design editor. Start with `frontend/architecture-and-workflow`.
- `backend/`: JVM Clojure HTTP/RPC server with PostgreSQL, Redis, storage, mail, and workers. Start with `backend/architecture-and-workflow`.
- `common/`: shared CLJC data types, geometry, schemas, file/change logic, and utilities. Start with `common/architecture-and-workflow`.
- `render-wasm/`: Rust -> WebAssembly Skia renderer consumed by frontend. Start with `render-wasm/architecture-and-workflow`.
- `exporter/`: ClojureScript/Node headless Playwright SVG/PDF export. Start with `exporter/architecture-and-workflow`.
- `mcp/`: TypeScript Model Context Protocol integration. Start with `mcp/architecture-and-workflow`.
- `plugins/`: TypeScript plugin runtime/examples and Plugin API types. Start with `plugins/architecture-and-workflow`.
- `library/`: design library workflows. Start with `library/architecture-and-workflow`.
- `docs/`: documentation site. Start with `workflow/docs`.

## Low-centrality paths

- `docker/` and root tooling are covered by `project/dev-ci-environment-workflow`; root scripts such as `scripts/lint`, `scripts/check-fmt`, and `scripts/fmt` are wrappers around module-local checks.
- `experiments/` contains standalone experimental HTML/JS/scripts; treat it as non-core unless the user explicitly asks about it.
- `sample_media/` contains sample image/icon media and config used as fixtures/demo material; do not infer app behavior from it.
- `.opencode/`, `opencode.json`, and agent/tooling config are project-local AI/dev tooling, not Penpot runtime code.

## Dependency graph

`frontend -> common`, `backend -> common`, `exporter -> common`, and `frontend -> render-wasm`. Changes in `common` can affect frontend, backend, exporter, file migrations, and design-library behavior; validate across consumers when semantics change.