# Geometry Invariants in Penpot Shapes

A shape's position is represented redundantly across several fields, and
they MUST agree. Many bugs (and many test-setup mistakes) come from
violating this.

## Redundant fields

For a shape at (x, y) with width w and height h:

- `:x`, `:y`, `:width`, `:height` — top-left and dimensions
- `:selrect` — `{:x :y :width :height :x1 :y1 :x2 :y2}` where x1=x, y1=y,
  x2=x+w, y2=y+h
- `:points` — `[p0 p1 p2 p3]` for an axis-aligned rect, in clockwise
  order from top-left
- `:transform` and `:transform-inverse` — for rotated shapes; identity
  for axis-aligned

After any geometric mutation, `:y` should equal `:selrect.y` should equal
`:points[0].y`. The renderer reads `:selrect`/`:points` for layout and
hit-testing, so an inconsistent shape will look wrong even if `:y` is
"correct" by some other metric.

## Helpers that PRESERVE the invariant

- `gsh/move shape (gpt/point dx dy)` — translate by delta. Updates
  everything consistently.
- `gsh/absolute-move shape (gpt/point x y)` — move to absolute position
  by computing the delta from the current selrect and applying `move`.
- `gsh/transform-shape` — applies a full transform.
- `cts/setup-shape` — for new shapes only. Initializes `:selrect`/`:points`
  from `:x`/`:y`/`:width`/`:height`/`:type`. The variant test helpers
  (`thv/add-variant-with-child`, etc.) use this and produce
  geometry-consistent shapes.

## Helpers that BREAK the invariant

- `(assoc shape :y …)` — only updates `:y`. `:selrect` and `:points`
  stay stale.
- `ths/update-shape file label :y val` (in test helpers) — goes through
  `set-shape-attr`, which preserves invariants for `:width`/`:height`
  via `gsh/close-attrs?` magic but **does NOT** for `:y` alone. Using
  this to position a shape produces an inconsistent state.
- Any direct `update-in shape [:selrect :width] inc` style edit.

## Implication for tests

When constructing test shapes at specific positions, ALWAYS go through
`gsh/absolute-move` or `gsh/move`, e.g.:

```clojure
(cls/generate-update-shapes (pcb/empty-changes nil page-id)
                            #{(:id child)}
                            #(gsh/absolute-move % (gpt/point (:x %) 101))
                            (:objects page) {})
```

Using `(ths/update-shape file label :y 101)` will leave `:selrect.y` at
its initial value, and downstream code that reads `:selrect` will
produce inconsistent results that look like bugs in OTHER code paths.

This is a brutally easy mistake to make and produces false-positive
test failures that look like "the bug" but are actually setup errors.

## :touched and geometry mutation

When the geometry of a copy shape changes via the proper pipeline
(`set-shape-attr` through `process-operation :set`), `:touched` gains
`:geometry-group` (assuming `in-copy? = true` and `ignore-touched`
isn't set). Tests that need to simulate this state can either:

(a) drive the proper update via `cls/generate-update-shapes`, OR
(b) directly inject `(assoc shape :touched #{:geometry-group})` while
    knowing this bypasses the geometry-consistency machinery.

Approach (b) is fine when the test only needs the touched state, not
the geometric change. But if the test ALSO needs the shape positioned
differently, do the position change FIRST (via `absolute-move`) and
then the touched injection.
