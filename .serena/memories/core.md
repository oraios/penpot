You are working on the GitHub project `penpot/penpot`.

# Memory reading protocol

1. Use Serena memories as the primary project guidance. Read `mem:project/core` for repo/module routing, module-specific memory selection, changelog routing, and dependency cautions.
2. Each memory subfolder's top-level memory is `<folder>/core`. When a subfolder is relevant, read its core memory before focused memories.
3. Focused memories assume their subfolder core memory has already been read. They should not repeat core routing/source-map content.
4. If Serena memory tools are unavailable, read the Markdown files directly from `.serena/memories/` in the project.

# Memory maintenance

For memory edits, stale memory refs, duplicated guidance, or memory-graph cleanup: read `mem:project/memory-maintenance`.

# Working with Penpot designs through MCP

Before automating or inspecting Penpot designs through the Plugin API, call the Penpot MCP `high_level_overview` tool. It explains the `execute_code` environment (`penpot`, `penpotUtils`, `storage`) and the available API surface.
