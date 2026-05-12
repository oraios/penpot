# Memory Maintenance

## Discovery Model

- Agents always start with the full memory name list plus `mem:core`.
- All other memory discovery comes from names plus routing already read.
- Add routing only when names are insufficient, ambiguous, or a non-obvious dependency/order matters.
- Do not add tautological routing such as "frontend debugging -> frontend/debugging".
- Routing can live outside intro memories when needed, but intro memories own most module-level routing.
- Top-level/startup memory is `mem:core`; top-level memory in each memory subfolder is `<folder>/core` (for example `mem:frontend/core`).
- Memory references must use a mem: prefix inside backticks, e.g. `mem:frontend/core`.

## Style

Dense agent notes, not prose docs. Prefer invariants, paths, commands, terse bullets. Avoid obvious context, rationale, and examples unless they prevent likely mistakes. Keep guidance durable and generalizable, not task-local.

## Add/update threshold

Add or update memory only for stable, non-obvious project conventions that avoid complex rediscovery.

Do not add: quick-read/rg facts; generic language/framework knowledge; one-off task notes; volatile line-level details; behavior likely to change soon.

Operational constants: phrase as current behavior; verify owning namespace before changing semantics.

## Graph Ownership

- Project-level routing: `mem:project/core`.
- Module-level routing/source maps: module core memories.
- Focused memories: topic details only; assume relevant routing was read before selection.

## Maintenance Actions

- Renamed/removed/split/merged/superseded memory: update all references.
- Stale paths/namespaces/commands/behavior: update or remove in owning memory.
- Split catch-all memory when sections are commonly needed independently or agents must read unrelated domains to reach needed topic.
- Retire/delete memory when owning module/subsystem is removed or replaced; remove all references.
- Added/renamed/split/moved/deleted memory: update affected routing only where names are insufficient.
- Before finishing: list memories for old names and key new names to catch stale/missing references.