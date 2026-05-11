# File Mutations: Changes & Undo Architecture

For validation, repair, migration, shape-tree, and second-pass touched details, also read `common/file-change-validation-migration-subtleties`.

Penpot mutates file data exclusively through "change" records. This is
both an undo mechanism and an audit log. Knowing how it works lets you
inspect what a UI action actually did.

## The shape of a change

Each change is a map `{:type … :id … :page-id … …}`. Common types:

- `:add-obj` / `:mod-obj` / `:del-obj` — shape lifecycle (mod-obj's
  payload is a vector of `:operations`, each `{:type :set :attr X
  :val Y :ignore-geometry … :ignore-touched …}` or
  `{:type :set-touched :touched #{...}}` etc.)
- `:add-component` / `:mod-component` / `:del-component` — component
  metadata in the library
- `:add-children` / `:remove-children` / `:reg-objects` — tree edits
- `:set-option`, `:add-page`, `:mov-page`, etc.

Each transaction has both `:redo-changes` and `:undo-changes` (inverse
ops). The undo stack stores transactions; the index can move backward
and forward.

## The changes-builder API

`common/src/app/common/files/changes_builder.cljc` (alias `pcb`) is the
fluent builder. Always start from `(pcb/empty-changes <it> <page-id>)`
or `(pcb/empty-changes nil <page-id>)` for tests.

Key functions:
- `pcb/with-page-id`, `pcb/with-objects`, `pcb/with-library-data`
  — set context for following operations
- `pcb/update-shapes ids update-fn` — emits `:mod-obj` with diff-derived
  `:set` ops. Optionally `{:with-objects? true}` passes objects to the
  update-fn, `{:ignore-touched true}` suppresses touched bookkeeping,
  `{:attrs #{...}}` restricts which attrs are diffed.
- `pcb/add-objects shapes` — `:add-obj` per shape
- `pcb/change-parent`, `pcb/remove-objects`, `pcb/resize-parents` —
  tree edits
- `pcb/add-component`, `pcb/update-component`, `pcb/mod-component` —
  library-level
- `pcb/set-translation? true` — flags the entire change set as a
  translation-only change (used to skip component-sync for performance)

## Inspecting what a UI action did

Via cljs-repl after triggering an action:

```clojure
;; Get the most recent N transactions from the undo stack
(let [items (get-in @app.main.store/state [:workspace-undo :items])
      n (count items)]
  (->> items
       (drop (max 0 (- n 5)))
       (map-indexed (fn [i it]
                      {:idx (+ i (max 0 (- n 5)))
                       :tags (:tags it)
                       :n (count (:redo-changes it))
                       :types (frequencies (map :type (:redo-changes it)))
                       :ids (mapv :id (:redo-changes it))}))))
```

The `:tags` field is informative: alt-duplication tags transactions
with `#{:alt-duplication}`, which makes them easy to spot in a sequence.

To see the full operations within a `:mod-obj`:

```clojure
(let [items (get-in @app.main.store/state [:workspace-undo :items])
      last-trans (last items)
      mod-obj (->> (:redo-changes last-trans)
                   (filter #(= :mod-obj (:type %)))
                   first)]
  (:operations mod-obj))
```

## Applying changes in tests

`thf/apply-changes` (in `app.common.test-helpers.files`) is the test
analog of the production change-applier. It validates by default — pass
`:validate? false` to skip if you're constructing intentionally-invalid
intermediate state.

The applier processes operations through the same `process-operation`
multimethod the production code uses (in
`common/src/app/common/files/changes.cljc`), so behaviour matches
production exactly.

## :touched and the change pipeline

When a `:set` op is processed for a geometry attr on a shape with
`:shape-ref`, the value of `:ignore-geometry` on the op governs whether
`:touched` gets `:geometry-group` added. `:ignore-touched` on the op
fully suppresses touched updates for any attr.

Modifier-pipeline operations (interactive transforms) compute a per-shape
`:ignore-tree` via `check-delta` and pass `:ignore-geometry?` accordingly:
the descendants of a uniformly-translated component copy get
`ignore-geometry? = true` (so a pure translation doesn't mark every
descendant as touched).
