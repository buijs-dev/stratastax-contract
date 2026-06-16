# Naming Conventions — stratastax-schema

## Table names

- `snake_case`, singular (`match`, not `matches`).
- **No prefix by default.** A prefix is added *only* when the natural name
  collides with a PostgreSQL reserved or special keyword:
  - `app_user` — `user` is a reserved word in PostgreSQL (it also has a
    special meaning as `CURRENT_USER`'s equivalent function).
  - `app_group` — `GROUP` is a reserved keyword (`GROUP BY`).
- Every other table uses its plain domain name with no prefix, even where
  a join/child table shares a stem (`group_member`, `playset_expansion`,
  `claim_request_target`).

This is a deliberate, explicit rule — not a per-table judgment call — so
that adding a new table never requires guessing whether it needs a prefix.
When in doubt: no prefix, unless PostgreSQL itself forces one.

## Column names

- `snake_case`.
- Foreign key columns are always `<referenced_table_singular>_id`
  (`recorder_user_id`, `game_id`), even when the referenced table has a
  prefix (`owner_user_id` → `app_user`, not `owner_app_user_id`) — the
  prefix is a PostgreSQL-keyword workaround, not part of the domain name,
  so it is dropped in FK column names for readability.
- Boolean columns read as a predicate (`edit_requests_enabled`, not
  `is_edit_requests_enabled` or `edit_requests_enabled_flag`).
- Timestamps: `created_at`, `updated_at` on every table; a specific
  lifecycle moment gets its own name (`locked_at`, `revoked_at`,
  `joined_at`) rather than being folded into `updated_at`.

## Constraint names

- `chk_<table>_<what>` for CHECK constraints.
- `fk_<table>_<referenced_table>` for explicitly named foreign keys (only
  needed when added via `ALTER TABLE` after the fact, e.g. deferred FKs).
- `uq_<table>_<column(s)>` for unique constraints/indexes.
- `ix_<table>_<column(s)>` for plain indexes.
