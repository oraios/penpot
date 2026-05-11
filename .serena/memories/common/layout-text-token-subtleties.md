# Common Layout, Text, Token, and Schema Subtleties

Use when changing common layout logic, text data conversion, design tokens, or shared schema/coercion behavior.

## Layout

- Layout container data and child layout-item data are removed by different helpers. Do not assume clearing a layout frame also clears all child layout metadata.
- Grid `assign-cells` ensures at least one column and row, skips absolute-position children, creates non-tracked rows/cols when children exceed tracked cells, and asserts that assigned cells do not overlap.
- Grid deassignment removes cells for shapes that are no longer direct children or have become absolute-positioned.
- Auto-positioning is not just sorting: some auto cells are converted to manual when empty/manual/span state would break the auto sequence, then auto single-span items can be compacted.
- `fix-overlaps` is marked dev-only and removes one overlapping cell, preferring empty cells first. Avoid depending on it as normal production repair.

## Text

- `app.common.text` is legacy DraftJS conversion support. New text work should prefer the newer text type namespaces unless specifically touching DraftJS conversion.
- DraftJS style values are encoded as Transit strings under `PENPOT$$$<key>$$$<encoded>` style names. `PENPOT_SELECTION` is a special marker.
- Text conversion uses Unicode code points on both CLJ and CLJS paths, not UTF-16 code units. This matters for offsets around emoji and astral characters.
- Draft conversion fixes gradient type strings back to keywords.
- Modern text content schema is narrow: root -> paragraph-set -> paragraph -> text nodes. `position-data` is derived layout/geometry/font fragment data and should be treated as generated state.

## Tokens

- `TokensLib` always ensures an internal hidden theme exists and defaults active themes to that hidden theme path. That hidden theme represents the UI state where active sets are controlled without modifying a user-created theme.
- `get-tokens-in-active-sets` merges tokens from sets selected by active themes in set order, so later active sets with the same token name override earlier ones.
- Activating a real theme in `common.logic.tokens` removes the hidden theme from the active-theme set unless it is the only active theme. Toggling active sets directly copies current active sets into the hidden theme.
- DTCG import/export deliberately hides the internal hidden theme: exports omit it from `$themes` and activeThemes, while `activeSets` records the hidden/current active sets.
- Single-set DTCG/legacy imports throw if no supported tokens are found. Multi-set import normalizes set names, keeps `tokenSetOrder`, rejects conflicting token path names, discards unsupported token types, and validates theme sets against existing sets.
- Token values stored on shapes are token names in `:applied-tokens`, not token ids. Renames and group renames must update those name paths.
- Token serialization has both Transit handlers for frontend/backend transport and Fresian handlers for internal file-data storage, with migrations for older token-lib internal versions.

## Schema

- `app.common.schema/json-transformer` has custom map-of key decoding/encoding, so map keys can be transformed based on the key schema instead of only the value schema.
- `check-fn` throws `ex-info` with default `:type :assertion`, `:code :data-validation`, and `::explain`. Prefer reusable `check-fn`/lazy validators in hot or repeated paths; `sm/check` creates a checker every call.
- `coercer` decodes with the JSON transformer and then checks. This is the common pattern for accepting external JSON-shaped data into internal types.