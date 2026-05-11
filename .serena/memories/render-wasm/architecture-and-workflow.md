# render-wasm Architecture and Workflow

Use this for renderer work after `project/agent-workflow-and-module-map`. `render-wasm/` is a Rust crate compiled to WebAssembly through Emscripten and Skia; the frontend loads the generated JS/WASM renderer. For stable FFI/memory/tile invalidation behavior, also read `render-wasm/ffi-rendering-subtleties`.

## Stable Architecture

- Exported functions live around `src/lib.rs` / `src/wapi.rs` and are called from ClojureScript bridge namespaces under `frontend/src/app/render_wasm*`.
- Global renderer state is a single unsafe `State`; access it only through the established `with_state!` / `with_state_mut!` macros.
- Rendering is tile-based: only viewport-relevant 512x512 tiles plus buffer are drawn.
- Updates are two-phase: ClojureScript calls exported setters to push shape data, then `render_frame()` performs Skia drawing.
- Shapes are stored in a flat UUID-indexed pool; hierarchy is tracked separately.

## Source Areas

- `src/state*`: renderer state structures.
- `src/render/` and `src/render.rs`: tile/surface render pipeline.
- `src/shapes/` and `src/shapes.rs`: shape data and Skia drawing.
- `src/wasm/`, `src/wasm.rs`, `src/mem.rs`: JS/WASM memory and interop helpers.
- `src/math/` and `src/view.rs`: geometry and viewport helpers.

## Build Environment

`./build` sources `_build_env`, which sets the Emscripten paths and `EMCC_CFLAGS`. The WASM heap starts at 256 MB and uses geometric growth.

## Commands

From `render-wasm/`:
- Build/copy frontend artifacts: `./build`.
- Watch rebuild: `./watch`.
- Rust tests: `./test` or `cargo test <name>`.
- Lint: `./lint`.
- Format check: `cargo fmt --check`.

Do not change exported WASM function signatures without updating the corresponding frontend bridge and verifying the frontend renderer path.