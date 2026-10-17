# Naming Conventions — stratastax-schema

The single source of truth for naming in the schemas of every service. Follow it exactly; do not
introduce ad hoc exceptions per migration. `./gradlew :stratastax-schema:verifyMigrations` checks
the rules marked ✔ against a real database (see [`verify-migrations.sh`](verify-migrations.sh)).

## Tables

- Singular, `snake_case` (`match`, `claim_request`, not `matches`).
- **No prefix**, except for a name that is a reserved word in PostgreSQL
  ([keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html)). Today that is
  only `user` and `group`, which become `app_user` and `app_group`. A name that merely feels
  generic (`match`, `membership`) stays as it is.
- A join table without an identity of its own is named after both sides (`group_member`,
  `playset_expansion`, `match_edit_expansion_change`) and has a composite primary key.

## Columns

- `snake_case`.
- Every table with an identity has `id BIGINT` (primary key, from `<table>_seq INCREMENT BY 50`) and
  `public_id UUID NOT NULL DEFAULT gen_random_uuid()`. The `public_id` is what the API exposes.
- **A foreign key always references the internal `id`, never `public_id`** ✔.
- Foreign key columns are `<referenced_entity>_id` (`game_id`, `user_id`), prefixed with the role
  when the role says more than the table (`owner_user_id`, `recorder_user_id`,
  `proposed_by_user_id`). The `app_` prefix is not part of the domain name and is dropped
  (`owner_user_id`, not `owner_app_user_id`).
- A reference to another service's entity is `<service>_<entity>_id UUID` holding that service's
  public id, without a foreign key (`candidate.engine_game_id`).
- The name of an entity, as shown to people, is `display_name`, in every table.
- Booleans read as a predicate (`edit_requests_enabled`, `is_expansion`, `is_self`); a flag that a
  value in a proposed change is set is `<column>_set` (`score_set`, `playset_set`).
- Enums are `VARCHAR` with a `CHECK (... IN (...))`, never a native `ENUM` type, so a value can be
  added without `ALTER TYPE`. Values are `UPPER_SNAKE_CASE`.

### Timestamps and versions

- Every table with a `public_id` has `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` and
  `updated_at TIMESTAMPTZ` ✔. Join tables without an identity may carry one lifecycle timestamp
  instead (`group_member.added_at`).
- A specific moment gets its own column **next to** `created_at`/`updated_at`, never instead of them:
  `joined_at`, `finalized_at`, `deleted_at` (soft delete), `decided_at`, `revoked_at`, `disputed_at`.
- Who did it is the same verb: `decided_by_user_id` with `decided_at` (every approve/reject
  workflow), `revoked_by_user_id` with `revoked_at`, `disputed_by_user_id` with `disputed_at`.
- Every entity that can be changed through the API has `version BIGINT NOT NULL` for optimistic
  locking; the API exposes it as the `ETag`.

## Constraints and indexes

Every constraint except the primary key is named, with the `CONSTRAINT` keyword ✔; there are no
inline `REFERENCES` or `UNIQUE` column constraints, so no constraint is ever declared twice ✔.

| Kind                     | Pattern                               | Example                                    |
|--------------------------|---------------------------------------|--------------------------------------------|
| Primary key              | inline, PostgreSQL's default name     | `id BIGINT PRIMARY KEY`                    |
| Foreign key              | `fk_<table>_<column>`                 | `fk_match_recorder_user_id`                |
| Unique constraint/index  | `uq_<table>_<columns>[_<qualifier>]`  | `uq_claim_edge_ghost_player_id_active`     |
| Check                    | `chk_<table>_<what>`                  | `chk_game_player_range`                    |
| Plain index              | `ix_<table>_<columns>`                | `ix_match_game_id`                         |

- `<columns>` are the column names in index order, joined with `_`. The qualifier of a partial
  unique index says which rows it covers (`_active`, `_pending`, `_self`).
- Every foreign key column is the leading column of an index ✔: PostgreSQL does not create one, and
  joins and deletes would otherwise scan the referencing table. A primary key or unique constraint
  that starts with the column counts.
- Names stay below 63 characters, where PostgreSQL silently truncates ✔. When a name would be
  longer, leave the `_id` suffix out of the column names in it
  (`uq_match_edit_participant_change_match_edit_participant`).

## Documentation

Every table gets a `COMMENT ON TABLE` ✔ (join tables excepted), and a column whose meaning is not
obvious a `COMMENT ON COLUMN`. The comments are published on
[docs.stratastax.dev](https://docs.stratastax.dev/technical/database/): write them for a reader outside
the project, and state there every invariant of [INVARIANTS.md](INVARIANTS.md) that starts at the table.
