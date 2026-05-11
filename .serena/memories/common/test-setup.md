# Common Module Test Setup

`common/` is CLJC shared code. Tests should cover the relevant runtime(s): JVM for backend/common logic and JS for frontend/exporter behavior. For geometry/component/file-model changes, JVM tests are common and fast, but JS/browser behavior can differ when WASM modifier math or CLJS-specific state is involved.

## Running Tests

From `common/`:

```bash
# JVM whole suite
pnpm run test:jvm
clojure -M:dev:test

# JVM single namespace/test
pnpm run test:jvm --focus common-tests.logic.variants-switch-test
clojure -M:dev:test --focus common-tests.logic.variants-switch-test/test-basic-switch

# JS whole suite
pnpm run test:js

# JS focused suite: edit test/common_tests/runner.cljs, then run
pnpm run test:js
```

Multiple JVM `--focus` flags compose as a union.

## Test Helpers

Helpers live under `common/src/app/common/test_helpers/`. Tests usually alias them with short `th*` prefixes. Always start test namespaces that use label->uuid helpers with `(t/use-fixtures :each thi/test-fixture)` so labels reset between tests.

## Common Builders

Build a file with a component:

```clojure
(-> (thf/sample-file :file1)
    (tho/add-simple-component :btn-comp :btn-root :btn-rect)
    (thc/instantiate-component :btn-comp :copy01))
```

Build a variant container with two variants:

```clojure
(thv/add-variant-with-child file
                            :v01 :c01 :m01 :c02 :m02 :r01 :r02
                            {:child1-params {:width 100 :height 24}
                             :child2-params {:width 100 :height 24}})
```

Build variants whose children are themselves component instances:

```clojure
(-> file
    (tho/add-simple-component :btn-comp :btn-root :btn-rect)
    (thv/add-variant-with-copy
     :v01 :c01 :m01 :c02 :m02 :child1 :child2 :btn-comp))
```

`add-variant-with-copy` does not accept position params for children; use `gsh/absolute-move` after creation if positions matter.

## Driving Production Paths

For shape mutations, prefer production-path helpers such as `cls/generate-update-shapes` plus `thf/apply-changes`. For component swaps with keep-touched behavior, use `tho/swap-component-in-shape` with `{:keep-touched? true}`.

`thf/apply-changes` validates by default and usually gives the most useful invariant failure. Pass `:validate? false` only for intentionally malformed intermediate state.

## Debugging

`thf/dump-file file :keys [:width :touched]` prints the shape tree with selected keys. Temporary `prn` calls in production code are useful during investigation but should be removed before committing.