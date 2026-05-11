# Project Agent Workflow and Module Map

Use this first after `critical-info` when starting a Penpot task from the memory list. It consolidates repository-level AGENTS guidance and routes you to focused memories.

## Working flow

- Identify the affected module(s), then read the focused memories for those modules instead of loading unrelated context.
- Be autonomous but keep edits scoped to the task and affected modules. Do not touch unrelated modules unless the change requires it.
- Before code changes, have a concrete plan. For larger tasks, break it into atomic steps and verify the result with the relevant focused checks.
- Search with `rg` / `rg --files` by default; it respects `.gitignore` and is the expected fast search path.
- Commit only when explicitly asked. For commit/PR format and changelog expectations, read `workflow/creating-commits` and `workflow/creating-prs`.
- For Docker/devenv, CI workflows, root tooling, or cross-module validation, read `project/dev-ci-environment-workflow`.
- For GitHub collaborator/PR metadata queries, read `workflow/github-queries`.

## Changelogs

- Main application/module changes (`backend`, `frontend`, `common`, `render-wasm`, `exporter`, `mcp`) use root `CHANGES.md`.
- Plugin subproject changes use `plugins/CHANGELOG.md`.
- Add entries under `## <version> (Unreleased)` in the matching category, usually `:sparkles: New features & Enhancements` or `:bug: Bugs fixed`.

## Stable module map

- `frontend/`: ClojureScript + SCSS SPA/design editor. Read `frontend/architecture-and-workflow`, then focused frontend memories. For JS package/text-editor/shared UI work, read `frontend/ui-packages-text-editor-workflow` and `frontend/ui-conventions-and-style-system`.
- `backend/`: JVM Clojure HTTP/RPC server with PostgreSQL, Redis, storage, mail, and workers. Read `backend/architecture-and-workflow`, then focused backend memories. For auth, permissions, teams/projects, invitations, comments, webhooks, or audit behavior, read `backend/auth-permissions-product-domains`.
- `common/`: shared CLJC data types, geometry, schemas, file/change logic, and utilities. Read `common/architecture-and-workflow`, then focused common memories.
- `render-wasm/`: Rust -> WebAssembly Skia renderer consumed by frontend. Read `render-wasm/architecture-and-workflow` and `render-wasm/ffi-rendering-subtleties`.
- `exporter/`: ClojureScript/Node headless Playwright SVG/PDF export. Read `exporter/architecture-and-workflow`.
- `mcp/`: TypeScript Model Context Protocol integration. Read `mcp/architecture-and-workflow`.
- `plugins/`: TypeScript plugin runtime/examples and Plugin API types. Read `plugins/architecture-and-workflow`.
- `library/`: design library workflows. Read `library/architecture-and-workflow` when touching library semantics.
- `docs/`: documentation site. Read `workflow/docs` for docs-only changes.

## Dependency graph

`frontend -> common`, `backend -> common`, `exporter -> common`, and `frontend -> render-wasm`. Changes in `common` can affect frontend, backend, exporter, file migrations, and design-library behavior; validate across consumers when semantics change.