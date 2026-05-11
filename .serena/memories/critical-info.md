You are working on the GitHub project `penpot/penpot`.

# Required first steps

1. Use Serena memories as the primary project guidance. Start with this `critical-info` memory, then read `project/agent-workflow-and-module-map` for repo/module routing.
2. Identify affected modules and read only the focused memories relevant to those modules. Prefer focused memories over broad architecture memories once you know the area.
3. If Serena memory tools are unavailable, read the Markdown files directly from `.serena/memories/` in the project.

# Memory maintenance while working

When code exploration reveals a stable, non-obvious project convention that would help future agents avoid complex rediscovery, update or add the relevant memory before finishing. Keep memories terse, generalizable, and tied to durable behavior rather than one task. When adding, renaming, splitting, or moving a memory, update cross-references in `critical-info`, `project/agent-workflow-and-module-map`, or the affected module architecture memory so incremental discovery still works.

# Cross-module caution

`common/` is shared CLJC used by frontend, backend, exporter, and file/library tooling. Treat geometry, component, file-model, tokens, schema, and change-pipeline behavior as shared contract, not local implementation detail.

# Working with Penpot designs through MCP

Before automating or inspecting Penpot designs through the Plugin API, call the Penpot MCP `high_level_overview` tool. It explains the `execute_code` environment (`penpot`, `penpotUtils`, `storage`) and the available API surface.

# Frontend compile vs runtime crash diagnostics

After CLJ/CLJC/CLJS source edits, stale hot reload, or a suspected bad build, read `frontend/compile-diagnostics` and use `cljs_compiler_output`. If the compiler error suggests unmatched delimiters, use `clj_check_parentheses` on the suspect source file.

If the compiler is healthy but the workspace shows Internal Error, or `execute_code` succeeds and the app crashes 1-2s later, read `frontend/handling-crashes`. A quick runtime crash check is cljs-repl: `(some? (:exception @app.main.store/state))`.