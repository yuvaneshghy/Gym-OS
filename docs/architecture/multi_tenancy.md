# Multi-Tenancy Architecture

GymKit uses a **strict isolation** model for multi-tenancy: **One PocketBase instance per client**.

## Why this approach?

Traditional SaaS applications use a single massive database and enforce separation via Row-Level Security (RLS) or `tenant_id` columns. While this works, it introduces risk (data leaks across tenants) and makes custom client requests (e.g., "Can we add this specific column for our gym?") difficult to manage.

PocketBase is incredibly lightweight (a single Go binary using SQLite). Running 100 PocketBase instances is often more efficient and infinitely safer than managing one massive monolithic database.

## How it works

1. **Deployments**: Each client (tenant) gets their own Docker container running PocketBase and their own `pb_data` directory.
2. **Migrations**: The `pb/pb_migrations/` and `pb/pb_hooks/` folders in the repo are shared. When a container spins up, it automatically applies the universal migrations, ensuring all clients have the same database schema.
3. **Routing**: Caddy reverse proxy routes traffic based on subdomains (e.g., `api-gym-a.domain.com` -> Container A, `api-gym-b.domain.com` -> Container B).
4. **App Targeting**: The Flutter app connects to the correct backend using `--dart-define=PB_URL=...` at build time.
