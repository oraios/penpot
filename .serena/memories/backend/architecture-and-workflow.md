# Backend Architecture and Workflow

Use this for backend work after `project/agent-workflow-and-module-map`. The backend is JVM Clojure using Integrant components, PostgreSQL, Redis/Valkey, RPC commands, HTTP routes, storage, mail, audit/logging, and background workers.

For stable non-obvious RPC/DB/worker behavior, read `backend/rpc-db-worker-subtleties`. For HTTP/session, storage/media, and file-data backend behavior, read `backend/http-storage-filedata-subtleties`. For auth, permissions, teams/projects, invitations, comments, webhooks, or audit/product-domain commands, read `backend/auth-permissions-product-domains`.

## Stable namespace map

- `app.rpc.commands.*`: RPC command implementations exposed under `/api/rpc/command/<cmd-name>`.
- `app.rpc.permissions`: permission predicate/check helper factories.
- `app.http.*`: HTTP routes and middleware.
- `app.auth.*`: provider-specific authentication helpers such as LDAP/OIDC.
- `app.loggers.*`: audit, webhook, database, and external log integrations.
- `app.db.*` / `app.db`: next.jdbc wrapper and SQL helpers.
- `app.tasks.*`: background task handlers.
- `app.worker`: task execution/cron plumbing.
- `app.main`: Integrant system map and component wiring.
- `app.config`: `PENPOT_*` env config and feature flags.

## RPC conventions

RPC commands are defined with `app.util.services/defmethod` and schemas. Use `get-` prefixes for read operations. Command metadata usually includes auth, docs version, params schema, and result schema. Return plain maps/vectors or raise structured exceptions from `app.common.exceptions`.

## DB conventions

`app.db` helpers accept cfg, pool, or conn in most places and convert kebab-case to snake_case:
- `db/get`, `db/get*`, `db/query`, `db/insert!`, `db/update!`, `db/delete!`.
- Use `db/run!` for multiple operations on one connection.
- Use `db/tx-run!` for transactions.

Development DB: `postgresql://penpot:penpot@postgres/penpot`.
Test DB: `postgresql://penpot:penpot@postgres/penpot_test`.
Migrations live in `backend/src/app/migrations/`; applied migrations are tracked in the `migrations` table.

## Background tasks

A task handler is an Integrant component with `ig/assert-key`, `ig/expand-key`, and `ig/init-key`, returning the function run by the worker. New tasks also need wiring in `app.main`: handler config, worker registry entry, and cron entry if scheduled.

## Commands

From `backend/`:
- Focused test: `clojure -M:dev:test --focus backend-tests.some-ns-test`.
- Full backend test suite: `clojure -M:dev:test` or `pnpm run test`.
- Lint: `pnpm run lint`.
- Format check: `pnpm run check-fmt`.
- Format fix: `pnpm run fmt`.

Use JVM type hints in performance-critical paths to avoid reflection.