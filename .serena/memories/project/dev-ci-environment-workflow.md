# Project Dev, Docker, and CI Environment Workflow

Use after `project/agent-workflow-and-module-map` when changing setup scripts, Docker/devenv files, root tooling, CI workflows, feature-flag setup, or cross-module validation. For module-specific commands, prefer the module architecture/testing memories.

## Root tooling

- Root `package.json` only exposes coarse `lint`, `check-fmt`, and `fmt` wrappers through root scripts. Most real checks are module-local and should be run from the affected module directory.
- `manage.sh` owns Docker/devenv operations and image build helpers. It sets the repository as a safe Git directory, computes architecture, and uses Docker Compose project `penpotdev` with `docker/devenv/docker-compose.yaml`.
- Standard local flow is `./manage.sh pull-devenv` then `./manage.sh run-devenv` for a tmux-based environment. `start-devenv`, `stop-devenv`, and `drop-devenv` manage background containers/volumes.
- `run-devenv-agentic` starts the devenv with Serena enabled and `PENPOT_FLAGS` including `enable-mcp`; use this path for agentic local workflows that need the Penpot MCP bridge.

## Docker devenv

- `docker/devenv/docker-compose.yaml` mounts the repo at `/home/penpot/penpot` in the main `penpotapp/devenv:latest` container and persists `/home/penpot` in a named volume.
- Core services are Postgres, Valkey/Redis, MinIO, mailcatcher, and optional LDAP/Keycloak-style auth services. The main service exposes frontend/backend/shadow-cljs, Storybook, MCP, plugin, MinIO, mail, and Serena ports.
- Devenv defaults include SMTP and LDAP environment variables. If a backend auth or email test behaves differently locally, check docker/devenv service env before assuming application logic changed.
- Penpot is usually available at `http://localhost:3449` in devenv; MailCatcher is at `http://localhost:1080`.
- If filesystem watchers miss changes on Linux, increasing `fs.inotify.max_user_watches` may be necessary.

## Feature flags and local config

- Frontend runtime config is the gitignored `frontend/resources/public/js/config.js`. Set globals such as `var penpotFlags = "enable-mcp enable-webhooks";` and reload the browser; no backend restart is needed for frontend-only flags.
- Backend/exporter config comes from environment variables such as `PENPOT_FLAGS`, usually in `docker/devenv/docker-compose.yaml`, backend scripts, or the current shell. Backend flag changes require backend process restart.
- Feature flag entries use `enable-<flag>` / `disable-<flag>`. Some features, e.g. access tokens, webhooks, MCP, or LDAP login, need both frontend UI flags and backend/API flags to work end-to-end.
- Team feature flags can be toggled in devenv through `/dbg` by entering a team id and feature name.
- The full flag list lives in `common/src/app/common/flags.cljc`.

## CI workflows

- Main CI is `.github/workflows/tests.yml`. It runs lint for common/frontend/backend/exporter/library, tests for common/frontend/render-wasm/backend/library, and plugin runtime/package checks.
- MCP has a path-filtered CI workflow in `.github/workflows/tests-mcp.yml` that runs setup, format check, recursive builds, and type checks for `mcp/**` changes.
- Build/deploy workflows for bundles, Docker images, staging/develop/tag releases, and plugin docs/packages live under `.github/workflows/`; do not infer CI coverage from only `tests.yml` when touching release or package publication behavior.
- CI generally runs in `penpotapp/devenv:latest`; local mismatches can come from using host tools instead of the devenv image.

## Agentic devenv

- First-time agentic setup may require `./manage.sh build-devenv --local` before running the agentic environment.
- `./manage.sh run-devenv-agentic` enables Serena and MCP-facing flags in the tmux environment.
- Penpot MCP in single-user devenv is usually reachable at `http://localhost:4401/mcp`; Serena at `http://localhost:14281/mcp` with dashboard `http://localhost:14282`.
- Browser automation through Playwright MCP needs a Chromium-family browser launched with remote debugging, e.g. `--remote-debugging-port=9222` and a separate user-data directory.

## Validation strategy

- Start with the focused module command from the relevant memory. Use root wrappers only when the change intentionally crosses module boundaries or touches shared tooling.
- For CI/workflow edits, inspect the exact workflow trigger paths, branches, container, and working-directory before changing commands.
- For Docker/devenv edits, prefer validating with `./manage.sh start-devenv`, `run-devenv-shell`, or the specific image build helper that owns the touched file.