# File Mutations: Changes and Undo Architecture

Use for `common/` work that mutates file data or needs to understand undo/redo. For validation, repair, migrations, shape-tree edits, and second-pass touched details, also read `common/file-change-validation-migration-subtleties`. For live inspection snippets, read `common/component-debugging-recipes`.

Penpot mutates file data through change records. A change set is both the persistence payload and the basis for undo/redo, so UI actions, tests, backend file updates, and library/file tooling should drive the production change pipeline instead of ad hoc object-map mutation.

## Change shape

Each change is a map such as `{:type ... :id ... :page-id ...}`. Common families:

- `:add-obj`, `:mod-obj`, `:del-obj`: shape lifecycle. `:mod-obj` contains `:operations`, commonly `{:type :set :attr ... :val ... :ignore-geometry ... :ignore-touched ...}` or `{:type :set-touched ...}`.
- `:add-component`, `:mod-component`, `:del-component`: component/library metadata.
- `:add-children`, `:remove-children`, `:reg-objects`: tree and object-map edits.
- `:set-option`, `:add-page`, `:mov-page`, and related file/page metadata changes.

Each transaction carries `:redo-changes` and inverse `:undo-changes`. The undo stack stores transactions and can move its index backward/forward.

## changes-builder API

`common/src/app/common/files/changes_builder.cljc` (usually alias `pcb`) is the fluent builder. Start from `(pcb/empty-changes <it> <page-id>)` or `(pcb/empty-changes nil <page-id>)` for tests.

High-value builder operations:
- `pcb/with-page-id`, `pcb/with-objects`, `pcb/with-library-data`: set context for following operations.
- `pcb/update-shapes ids update-fn`: emits `:mod-obj` with diff-derived `:set` ops. Options include `{:with-objects? true}`, `{:ignore-touched true}`, and `{:attrs #{...}}`.
- `pcb/add-objects`, `pcb/change-parent`, `pcb/remove-objects`, `pcb/resize-parents`: shape/tree edits.
- `pcb/add-component`, `pcb/update-component`, `pcb/mod-component`: component/library edits.
- `pcb/set-translation? true`: marks the whole change set as translation-only, which lets component sync skip expensive work.

## Applying changes in tests

`thf/apply-changes` in `app.common.test-helpers.files` is the test analog of the production applier. It validates by default; pass `:validate? false` only for intentionally-invalid intermediate states.

The applier uses the same `process-operation` multimethod as production (`common/src/app/common/files/changes.cljc`), so tests that use it exercise production behavior.

## :touched and geometry

When a `:set` op changes a geometry attr on a shape with `:shape-ref`, `:ignore-geometry` controls whether `:geometry-group` is added to `:touched`. `:ignore-touched` suppresses touched updates for any attr.

Interactive transform/modifier code computes per-shape `ignore-geometry?` through the ignore-tree/check-delta path. A pure translation of a component copy can avoid marking every descendant as geometry-touched, while resize/rotation still propagates touched state.

## Inspection

To inspect what a UI action emitted, use `frontend/cljs-repl` with the snippets in `common/component-debugging-recipes` rather than adding temporary source instrumentation.