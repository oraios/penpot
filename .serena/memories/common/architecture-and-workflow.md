# Common Architecture and Workflow

Use this for `common/` work after `project/agent-workflow-and-module-map`. The module is shared CLJC used by frontend, backend, exporter, library/file tooling, and some tests; small behavior changes can affect multiple runtimes.

## Stable namespace map

- `app.common.types.*`: shared shape/file/page/component data types and Malli schemas.
- `app.common.files.*`: file data mutation, change application, undo/redo-related logic.
- `app.common.logic.*`: higher-level operations over files/shapes/components.
- `app.common.geom.*`: geometry helpers and transformations.
- `app.common.schema` / `app.common.schema.*`: Malli abstraction layer.
- `app.common.data` and `app.common.data.macros`: shared helpers and performance macros.
- `app.common.math`, `app.common.time`, `app.common.uuid`, `app.common.json`, etc.: cross-runtime utilities.
- `app.common.test_helpers.*`: test builders and production-path helpers.

## Cross-runtime rules

Use reader conditionals for platform-specific code. Because CLJC runs on JVM and CLJS targets, avoid assuming browser-only or JVM-only behavior unless the reader conditional isolates it.

Geometry, component, migration, validation, and change-pipeline behavior is especially subtle. Before changing those areas, read the targeted memories:
- geometry: `common/geometry-invariants`, `common/decimals-and-coordinates`;
- file mutation/change records: `common/changes-architecture`, `common/file-change-validation-migration-subtleties`;
- components/variants: `common/component-data-model`, `common/component-swap-pipeline`;
- debugging common change/component behavior: `common/component-debugging-recipes`;
- layout/text/tokens/schema: `common/layout-text-token-subtleties`;
- tests: `common/test-setup`.

## Commands

From `common/`:
- JVM tests: `pnpm run test:jvm` or `clojure -M:dev:test`.
- Focused JVM test: `pnpm run test:jvm --focus common-tests.some-ns-test` or `clojure -M:dev:test --focus ...`.
- JS tests: `pnpm run test:js`.
- Focused JS tests: edit `test/common_tests/runner.cljs`, then run `pnpm run test:js`.
- Watch JS tests: `pnpm run watch:test`.
- Lint: `pnpm run lint` or `pnpm run lint:clj`.
- Format check/fix: `pnpm run check-fmt:clj` / `pnpm run fmt:clj`; JS helpers use `check-fmt:js` / `fmt:js`.