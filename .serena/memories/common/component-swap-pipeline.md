# Component Swap & Variant Switch Pipeline

The flow that turns a UI variant-switch action (or a `swap-component`
operation) into actual shape mutations.

## Entry points

UI side (frontend/src/app/main/data/workspace/):
- `variants.cljs` — `variants-switch` and `variant-switch` events are
  the entry for the property-toggle UI and the plugin's `switchVariant`
  JS API. Both feed into `dwl/component-swap`.
- `libraries.cljs` — `component-swap` is the workhorse; `component-multi-swap`
  is a batch entry that calls `component-swap` with `keep-touched? = false`.

The discriminator that triggers the keep-touched logic is
`keep-touched? = true` — only `variant-switch` passes that. The
`component-multi-swap` path bypasses keep-touched entirely.

## Common-side pipeline

For a single swap with `keep-touched? = true`:

1. `cll/generate-component-swap`
   (in `common/src/app/common/logic/libraries.cljc`) builds the basic
   change set: removes the old shape, instantiates the new component
   in its place via `generate-new-shape-for-swap` →
   `generate-instantiate-component` → `make-component-instance`.
   The new shape's geometry is fresh from the target master.

2. `clv/generate-keep-touched`
   (in `common/src/app/common/logic/variants.cljc`) then walks the
   original (pre-swap) children, augments each with chain-derived
   touched flags via `add-touched-from-ref-chain`, finds the matching
   shape in the new tree (via `find-shape-ref-child-of`), and calls
   `update-attrs-on-switch` for each.

3. `update-attrs-on-switch`
   (in `app.common.logic.libraries`) is the per-shape attribute-copying
   routine. It's where the heavy lifting (and most of the bugs) live.

## update-attrs-on-switch in detail

Takes `current-shape` (freshly instantiated from target master),
`previous-shape` (pre-swap, augmented with chain touched), and
`origin-ref-shape` (the source variant master's equivalent, found
via `find-shape-ref-child-of`).

Loops over `updatable-attrs` (= `(keys ctk/sync-attrs) - swap-keep-attrs`)
and decides per attr whether to copy from `previous-shape` to
`current-shape`. The decision tree (heavily abridged):

```
For each attr:
  skip if (= prev-val curr-val)
  skip if equal-geometry?(prev, origin-ref, attr)   ;; selrect/points only
  skip if not (touched (resolve-sync-group attr))
  skip if (attr ∉ {:points :selrect :content})
            and (not= origin-ref-attr current-attr)  ;; "different masters"
  skip if for selrect/points: not :fix sizing AND
            (or (not= origin-ref-w current-w) (not= origin-ref-h current-h))

  ;; Otherwise copy:
  for text shapes with auto-grow:        switch-text-change-value
  for path shapes:                       switch-path-change-value
  for :fix sizing + selrect/points/w/h:  switch-fixed-layout-geom-change-value
  else:                                  (get previous-shape attr)   ← danger
```

The `:else` branch is where "user override carries through" semantically
should land — but it also catches cases the guards fail to filter,
producing inconsistent shapes.

## Known sharp edges

- The "different masters" skip BYPASSES `:selrect` and `:points`
  because they're composite. The width/height safety check that's
  supposed to compensate only catches dimension differences, not
  position differences within the parent.
- `previous-shape` is `reposition-shape`d before use, translating it
  by (dest-root - origin-root) — usually zero for variant switch
  because both instances share `:x`/`:y`.

## Test harness

`common/src/app/common/test_helpers/compositions.cljc` has
`swap-component-in-shape` which directly drives
`generate-component-swap` + `generate-keep-touched` with the same
`keep-touched? = true` flag. This is the canonical way to write
unit tests against the production swap path. The companion file
`common/test/common_tests/logic/variants_switch_test.cljc` has 40+
tests covering swap+touched scenarios — read it before adding a new
test in this area.

## Live debugging recipe

To capture exactly what `update-attrs-on-switch` saw during a real
UI swap, monkey-patch it in the cljs-repl:

```clojure
(def orig (deref #'app.common.logic.libraries/update-attrs-on-switch))
(def trace-buf (atom []))
(set! app.common.logic.libraries/update-attrs-on-switch
      (fn [& args]
        (swap! trace-buf conj
               (let [[_ curr prev _ _ origin _] args]
                 {:curr (select-keys curr [:name :y :selrect])
                  :prev (select-keys prev [:y :selrect :touched])
                  :origin-ref-id (:id origin)
                  :origin-ref-w (:width origin)}))
        (apply orig args)))
;; ... trigger UI action ...
@trace-buf
;; restore
(set! app.common.logic.libraries/update-attrs-on-switch orig)
```

Faster and more reliable than instrumenting source files (no recompile,
no need to clean up).
