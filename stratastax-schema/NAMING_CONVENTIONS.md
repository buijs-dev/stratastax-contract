# Naming Conventions — stratastax-schema

This document is the single source of truth for naming decisions in this
schema. Follow it exactly; do not introduce ad hoc exceptions per migration.

## Table names

- Singular, `snake_case` (e.g. `match`, `credential`, `claim_request`).
- No prefixes, with exactly one exception below.

## The only exception: reserved SQL keywords

Two domain terms collide with reserved words in the SQL standard / Postgres:

- `user` — reserved (also a built-in Postgres function name)
- `group` — reserved (used in `GROUP BY`)

For these two, and *only* these two, prefix with `app_`:

- `app_user`
- `app_group`

No other table in this schema should ever be prefixed. Before adding a new
table, check whether its bare name collides with a reserved word
(https://www.postgresql.org/docs/current/sql-keywords-appendix.html). If it
doesn't, do not prefix it — even if it "feels" generic (e.g. `match`,
`membership` stay as-is).

## Column names

- `snake_case`.
- Foreign keys: `<referenced_table_singular>_id` (e.g. `user_id`,
  `match_id`), except where the domain gives the reference a specific role
  distinct from the table name (e.g. `recorder_user_id`, `owner_user_id`,
  `proposed_by_user_id`, `approved_by_user_id` — all reference `app_user`,
  but the column name communicates *which* role, per "Explicit over
  Implicit").
- Timestamps: `created_at`, `updated_at` on every table; role-specific
  timestamps use a clear name (`joined_at`, `locked_at`, `revoked_at`).

## Enums

- `VARCHAR` + `CHECK` constraint, not native Postgres `ENUM` types — easier
  to extend later without an `ALTER TYPE` migration.
- Constraint values are `UPPER_SNAKE_CASE` (e.g. `PRIVILEGED_ACCESS`).
