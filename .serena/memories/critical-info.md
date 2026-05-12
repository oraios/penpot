You are working on the GitHub project `penpot/penpot`.

# Memory reading protocol

1. Use Serena memories as the primary project guidance. Read `project/agent-workflow-and-module-map` for repo/module routing, module-specific memory selection, changelog routing, and dependency cautions.
2. Each subsection has an introductory memory, usually `<subsection>/architecture-and-workflow`. When a subsection is relevant, read its introductory memory before its focused memories.
3. Focused memories assume their subsection introductory memory has already been read. They should not point back to that intro memory or repeat its routing/source-map content.
4. If Serena memory tools are unavailable, read the Markdown files directly from `.serena/memories/` in the project.

# Memory maintenance while working

Apply this section whenever you read a memory and notice stale guidance, stale memory names, stale code references, duplicated details, or a durable convention missing from the memory graph.

When code exploration reveals a stable, non-obvious project convention that would help future agents avoid complex rediscovery, update or add the relevant memory before finishing. Keep memories terse, generalizable, and tied to durable behavior rather than one task.

Do not add a memory for facts that are obvious from a quick read/rg/grep, generic language/framework knowledge, one-off task notes, volatile line-level implementation details, or behavior likely to change soon. When a memory mentions operational constants such as timeouts, batch sizes, caps, or intervals, phrase them as current behavior and verify the owning namespace before changing those semantics.

Preserve the reading protocol above: project routing belongs in `project/agent-workflow-and-module-map`; subsection routing/source maps belong in subsection introductory memories; focused memories own topic details and should not point back to their subsection intro memory.

If a memory references a memory that was renamed, removed, split, merged, or superseded, correct that reference before finishing. If a memory references code paths, namespaces, commands, or behavior that exploration shows are stale, update or remove the stale guidance in the owning memory.

Split a memory when it becomes a catch-all whose sections are commonly needed independently, or when agents must read unrelated domains to reach the topic they need. Retire/delete a memory when the owning module/subsystem is removed or replaced, and remove all references to it.

When adding, renaming, splitting, moving, or deleting a memory, update routing in `project/agent-workflow-and-module-map` and affected subsection introductory memories so incremental discovery still works. Before finishing memory maintenance, list memories for old memory names and key new memory names to catch stale or missing references.

# Working with Penpot designs through MCP

Before automating or inspecting Penpot designs through the Plugin API, call the Penpot MCP `high_level_overview` tool. It explains the `execute_code` environment (`penpot`, `penpotUtils`, `storage`) and the available API surface.

# Frontend diagnostics routing

For stale hot reload or failed CLJ/CLJC/CLJS source builds, read `frontend/compile-diagnostics`. For Internal Error pages or delayed runtime crashes after automation/API actions, read `frontend/handling-crashes`.