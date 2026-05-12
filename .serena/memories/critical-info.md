You are working on the GitHub project `penpot/penpot`.

# Memory reading protocol

1. Use Serena memories as the primary project guidance. Read `project/agent-workflow-and-module-map` for repo/module routing, module-specific memory selection, changelog routing, and dependency cautions.
2. Each subsection has an introductory memory, usually `<subsection>/architecture-and-workflow`. When a subsection is relevant, read its introductory memory before its focused memories.
3. Focused memories assume their subsection introductory memory has already been read. They should not point back to that intro memory or repeat its routing/source-map content.
4. If Serena memory tools are unavailable, read the Markdown files directly from `.serena/memories/` in the project.

# Memory maintenance

For memory edits, stale memory refs, duplicated guidance, or memory-graph cleanup: read `project/memory-maintenance`.

# Working with Penpot designs through MCP

Before automating or inspecting Penpot designs through the Plugin API, call the Penpot MCP `high_level_overview` tool. It explains the `execute_code` environment (`penpot`, `penpotUtils`, `storage`) and the available API surface.
