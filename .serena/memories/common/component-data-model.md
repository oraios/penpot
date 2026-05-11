# Component & Variant Data Model

Penpot's component system has subtle invariants that govern how shapes relate
to their masters, and several distinct "kinds" of shape that look similar at
first glance.

## Three kinds of shape relative to a component

1. **Master / main instance** — the original shape that defines a component.
   Has `:main-instance true` and `:component-id`. The variant masters
   (e.g. m01, m02 inside a variant container) are themselves main instances.
2. **Copy / non-main instance** — a shape produced by instantiating a
   component. Carries `:shape-ref` pointing at the master shape it was
   cloned from. Predicate: `(ctk/in-component-copy? shape)` is just
   `(some? (:shape-ref shape))`.
3. **Component root** — the topmost shape of an instance (whether master
   or copy). Has `:component-root true` and the surface attributes
   `:component-id` / `:component-file`. Inner descendants of the same
   instance have neither.

A shape can be all three at once: a variant master is a main instance AND
a component root, AND if its children are themselves instances of other
components, those children are *copies* (with `:shape-ref`) inside a
master. This nested-instance setup is the production scenario for many
real-world components like buttons inside variant frames.

## :shape-ref chains

`:shape-ref` walks "up" the inheritance hierarchy. `find-ref-shape` and
`get-ref-chain-until-target-ref` (in `app.common.types.file`) follow
this chain. The chain can cross files (when the upstream master is in
a remote library).

`find-shape-ref-child-of` (in `app.common.logic.variants`) walks the
chain looking for the first ref-shape whose ancestors include a
specific parent — used in variant-switch to find the equivalent master
shape for the *target* variant.

## :touched flags

`:touched` is a set of override-group keywords (e.g. `:geometry-group`,
`:fill-group`, `:text-content-group`). It marks that the COPY has
diverged from its master on attributes belonging to that group.

`sync-attrs` (in `app.common.types.component`) maps individual attrs
to their group: `:x :y :width :height :selrect :points :rotation
:transform` → `:geometry-group`; `:fills` → `:fill-group`; etc.

`set-touched-group` is the only legitimate setter. The central
`set-shape-attr` (in `app.common.types.container`) calls it from inside
a guard `(and in-copy? (not ignore?) ...)` — masters are not supposed
to carry `:touched` flags from this path. But `:touched` CAN end up on
master shapes via `duplicate-component` (see below).

`add-touched-from-ref-chain` (in `app.common.logic.variants`) walks a
copy's ref chain and inherits the union of `:touched` flags found on
ancestors onto the copy's `:touched`. This is how "the master is touched"
becomes visible when processing a copy.

## duplicate-component vs make-component-instance

These two functions have similar names and clone shapes from a component,
but they have a **critical** behavioural difference:

- `make-component-instance` (in `app.common.types.container`,
  via `update-new-shape`) **dissocs** `:touched`, `:variant-id`, and
  `:variant-name` on every cloned shape. The result is a clean copy.
- `duplicate-component` (in `app.common.logic.libraries`,
  via `update-new-shape`) only sets `:component-id`, optionally
  `:component-file`, `:variant-id` on the root, and applies a position
  delta. It does **NOT** dissoc `:touched`. So the new master inherits
  whatever touched flags the source master had.

If you alt-drag a variant whose master child has `:touched` (e.g. because
the variant master is itself a copy of an upstream component), the new
auto-created variant master inherits those touched flags. Combined with
ref-chain walking, this leaks touched state from the original master's
copy state into the new variant's switch behaviour.

## Variant containers

A variant container is a frame with `:is-variant-container true`. Its
children are variant masters, each with `:variant-id` (= container id)
and `:variant-name` (e.g. "Value 1", "Value 2"). The components themselves
(in the library's `:components` map) carry `:variant-properties` describing
property names/values.

Predicates: `ctk/is-variant?` is just `(some? (:variant-id item))` and
applies to BOTH the master shape and the component-row in the library.
`ctk/is-variant-container?` checks the `:is-variant-container` flag on
a shape.

## Auto-conversion to variants in generate-relocate

Beware: dropping a shape into a variant container via the move-to-frame
path (`generate-relocate` in `app.common.logic.shapes`) can auto-convert
the dropped shape into a variant via `generate-make-shapes-variant`,
which can in turn trigger `duplicate-component` for the underlying
component. This is what makes alt-drag-into-container produce phantom
"Value N" variant masters.
