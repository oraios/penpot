# Project Dev, Docker, and CI Environment Workflow

Use after `project/agent-workflow-and-module-map` when changing setup scripts, Docker/devenv files, root tooling, CI workflows, or cross-module validation. For module-specific commands, prefer the module architecture/testing memories.

## Root tooling

- Root `package.json` only exposes coarse `lint`, `check-fmt`, and `fmt` wrappers through root scripts. Most real checks are module-local and should be run from the affected module directory.
- `manage.sh` owns Docker/devenv operations and image build helpers. It sets the repository as a safe Git directory, computes architecture, and uses Docker Compose project `penpotdev` with `docker/devenv/docker-compose.yaml`.
- `run-devenv-agentic` starts the devenv with Serena enabled and `PENPOT_FLAGS` including `enable-mcp`; use this path for agentic local workflows that need the Penpot MCP bridge.

## Docker devenv

- `docker/devenv/docker-compose.yaml` mounts the repo at `/home/penpot/penpot` in the main `penpotapp/devenv:latest` container and persists `/home/penpot` in a named volume.
- Core services are Postgres, Valkey/Redis, MinIO, mailcatcher, and optional LDAP/Keycloak-style auth services. The main service exposes frontend/backend/shadow-cljs, Storybook, MCP, plugin, MinIO, mail, and Serena ports.
- Devenv defaults include SMTP and LDAP environment variables. If a backend auth or email test behaves differently locally, check docker/devenv service env before assuming application logic changed.

## CI workflows

- Main CI is `.github/workflows/tests.yml`. It runs lint for common/frontend/backend/exporter/library, tests for common/frontend/render-wasm/backend/library, and plugin runtime/package checks.
- MCP has a path-filtered CI workflow in `.github/workflows/tests-mcp.yml` that runs setup, format check, recursive builds, and type checks for `mcp/**` changes.
- Build/deploy workflows for bundles, Docker images, staging/develop/tag releases, and plugin docs/packages live under `.github/workflows/`; do not infer CI coverage from only `tests.yml` when touching release or package publication behavior.
- CI generally runs in `penpotapp/devenv:latest`; local mismatches can come from using host tools instead of the devenv image.

## Validation strategy

- Start with the focused module command from the relevant memory. Use root wrappers only when the change intentionally crosses module boundaries or touches shared tooling.
- For CI/workflow edits, inspect the exact workflow trigger paths, branches, container, and working-directory before changing commands.
- For Docker/devenv edits, prefer validating with `./manage.sh start-devenv`, `run-devenv-shell`, or the specific image build helper that owns the touched file.