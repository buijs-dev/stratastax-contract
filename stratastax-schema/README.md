# Stratastax Schema

This module contains the database schema definitions and migration scripts for the Stratastax services,
one directory per service:

| Directory                              | Service                  | Contents                                   |
|----------------------------------------|--------------------------|--------------------------------------------|
| `db/migration/engine/v1`               | stratastax-engine        | versioned migrations (owns games/expansions) |
| `db/migration/engine/testdata`         | stratastax-engine        | seed data for dev and test, never in an image |
| `db/migration/game-catalog/v1`         | stratastax-game-catalog  | candidates, BGG ranking, raw artifacts, pipeline control, idempotency |
| `db/migration/game-catalog/testdata`   | stratastax-game-catalog  | seed data for dev and test                 |
| `db/migration/i18n/v1`                 | i18n service (CMS)       | applications, message keys, translations, releases, idempotency |
| `db/migration/i18n/testdata`           | i18n service (CMS)       | seed data for dev and test                 |

Naming follows [NAMING.md](NAMING.md); the invariants that the database deliberately does not enforce
are listed in [INVARIANTS.md](INVARIANTS.md).

Every service gets its own migration image (`database-schema-engine`, `database-schema-game-catalog`,
`database-schema-i18n`) with only
its `v1` scripts: `./docker-build.sh <engine|game-catalog|i18n>`. The seeds refer to each other: the game-catalog seed's
published candidate points at the engine seed's game ids (fixed `public_id`s).

## Seed data

The `testdata` scripts fill a dev or test database with example data. They keep their own Flyway history
table, `flyway_testdata_history`, apart from the `flyway_schema_history` of the versioned migrations, so a new
`v1` migration never lands "out of order" behind seed scripts that already ran. Apply them with a second Flyway
run after the versioned migrations:

```bash
flyway -locations=filesystem:.../<service>/v1 migrate
flyway -locations=filesystem:.../<service>/testdata -table=flyway_testdata_history \
       -baselineOnMigrate=true -baselineVersion=0 migrate
```

The seed data is deterministic: fixed public ids (`0192f000-<kind>-7000-8000-<n>`, one `<kind>` per table, see
`V900__seed_users.sql`), fixed timestamps on and before 2026-01-01 12:00 UTC, and no `random()` or `now()`.
Every database built from these scripts holds exactly the same data, so tests can refer to it.

## Verification

`./gradlew :stratastax-schema:verifyMigrations` (part of `check`, needs Docker) runs
[`verify-migrations.sh`](verify-migrations.sh) per service: it applies `v1` and `testdata` to a throwaway Postgres
as described above, checks the naming and structure rules of NAMING.md and the seed data
(`src/main/verify-migrations`), and builds a second database to prove the seed data is identical.

## Schema documentation

`./gradlew generateSchemaDocs` (or `./generate-docs.sh <engine|game-catalog|i18n> [output-dir]` after `./gradlew jar`)
generates Markdown and SVG ER diagrams per service with [tbls](https://github.com/k1LoW/tbls), into
`build/schema-docs/<service>`. It needs Docker: the `v1` migrations of the service are applied to a throwaway
Postgres, which is removed afterwards. The same script runs in the build of
[docs.stratastax.dev](https://docs.stratastax.dev/technical/database/), so its output is **public**:

- only the `v1` migrations are applied, never `testdata`, so the docs show structure and no data;
- [`tbls.yml`](tbls.yml) leaves out `flyway_schema_history`, and the connection string (a local throwaway
  database) is passed through the environment, not written into the output;
- the docs never run against a real database.

### Checklist for a new migration

The migrations and seeds are public as well. Before adding one:

- no secrets, real hostnames or connection strings, in SQL or in comments;
- no real personal data in `testdata`: names are made up, e-mail addresses use `example.test`;
- a `COMMENT ON` is documentation on the site: write it for a reader outside the project;
- names, constraints and indexes follow [NAMING.md](NAMING.md), and an invariant the database does not enforce goes
  into [INVARIANTS.md](INVARIANTS.md) and the table's comment;
- seed data stays deterministic (fixed public ids and timestamps);
- `./gradlew :stratastax-schema:verifyMigrations` passes.

## Infrastructure & Deployment

### Docker Entrypoint (`src/main/docker/entrypoint.sh`)
The Docker image uses a custom entrypoint that runs a single Flyway migration against `filesystem:/flyway/migrations` with up to 10 connection retries and `baselineOnMigrate=true`.
- **Configuration**: Connection details are supplied via environment variables (`FLYWAY_URL`, `FLYWAY_USER`, `FLYWAY_PASSWORD`).

## Engine Schema Migrations (`src/main/resources/db/migration/engine/v1`)

These scripts define the core Stratastax domain model.

### Users and players

-   **`V1__create_user.sql`**: `app_user` ("app_" prefix: USER is reserved). Created together with a canonical player, a self ghost player and three privacy settings.
-   **`V2__user_identity.sql`**: `app_user_identity`, the ways to sign in as a user (identity provider + subject).
-   **`V3__create_canonical_player.sql`**: the authoritative identity of a person in gaming history.
-   **`V4__create_ghost_player.sql`**: players as a recorder knows them, in the recorder's own list; soft-deleted. `is_self` marks the ghost player that represents the owner, which is never deleted.

### Catalogue

-   **`V5__create_game.sql`**: the games, created and updated by the game catalog (`source_ref` says where a game came from, e.g. `bgg:199792`, and is unique).
-   **`V6__create_expansion.sql`**: expansions of a game, with a unique `source_ref` as well.

### Groups, playsets and communities

-   **`V7__create_group.sql`**: `app_group` ("app_" prefix: GROUP is reserved) and `group_member`; soft-deleted.
-   **`V8__create_playset.sql`**: reusable match configurations of one game, with their expansions; soft-deleted.
-   **`V9__create_community.sql`**: communities and their memberships; soft-deleted.
-   **`V10__create_membership_request.sql`**: requests to join a community with the REQUIRES_APPROVAL join policy, at most one pending per user.

### Matches

-   **`V11__create_match.sql`**: the aggregate root of gaming history and its expansions. DRAFT until `finalized_at` is set; soft-deleted.
-   **`V12__create_match_loadout.sql`**: per-participant configuration (faction, character, ...), owned by the participant that refers to it and deleted with it.
-   **`V13__create_match_participant.sql`**: a player's result in a match (`score NUMERIC(10,2)`, rank, outcome, loadout) and the dispute of a claimed player.
-   **`V14__create_claim_request.sql`**: proposals to link ghost players to a canonical player.
-   **`V15__create_claim_edge.sql`**: the approved, revocable links; at most one active per ghost player.
-   **`V16__create_match_edit.sql`**: proposed changes to a finalized match, fully normalized: result changes (`match_edit_participant_change`), loadout changes (`match_edit_loadout_change`), the new expansions (`match_edit_expansion_change`) and the new playset (on `match_edit`). The `*_set` flags tell "keep the current value" apart from "clear it".
-   **`V17__create_trusted_editor.sql`**: grants by which a recorder has the edits of a trustee approved automatically.

### Privacy and infrastructure

-   **`V18__create_privacy_setting.sql`**: one privacy level per user and data type (PROFILE, MATCH_HISTORY, MATCH_DETAILS), with the groups that get privileged access.
-   **`V19__create_idempotency_record.sql`**: the stored responses of mutating requests, replayed for a repeated `Idempotency-Key` (the reference DDL of stratastax-http's `idempotency-reactive`).

## Game Catalog Schema Migrations (`src/main/resources/db/migration/game-catalog/v1`)

-   **`V1__create_candidate.sql`**: games and expansions on their way into the engine, with the reliability checks of the LLM's reading of the rules. `engine_game_id` and `engine_expansion_id` hold the engine's public ids (no foreign key: the engine owns them).
-   **`V2__create_bgg_ranking.sql`**: the rows of the imported BGG ranking, linked to their candidate once it exists.
-   **`V3__create_raw_artifact.sql`**: the source material behind a candidate (BGG response, web search, LLM extraction).
-   **`V4__create_pipeline_control.sql`**: the run state (paused, suspended) of every automatic pipeline step.
-   **`V5__create_idempotency_record.sql`**: same as the engine's V19.

## I18n Schema Migrations (`src/main/resources/db/migration/i18n/v1`)

The storage behind `stratastax.i18n.api-v1.yaml`: the translation CMS, where admins translate the keys of an
application and publish them, and the bundles that consumer apps load at startup.

-   **`V1__create_user.sql`**: `app_user`, the CMS users as known from the identity provider (`subject` is the
    JWT `sub`), created on their first change; its `public_id` is the user reference in the API.
-   **`V2__create_application.sql`**: `application` (`application_key` is the slug in the API, such as
    `match-tracker`) and its locales in `application_locale`, the base locale included.
-   **`V3__create_message_key.sql`**: `message_key`, the keys with their base text, as imported from the translation
    files of the application (`obsoleted_at` once an import no longer contains a key), and their ICU arguments in
    `message_argument`, in the order in which the generated code passes them.
-   **`V4__create_release.sql`**: `release`, the publications numbered per application, and the locales each one
    published in `release_locale`. A release never changes.
-   **`V5__create_translation.sql`**: `translation`, per key and locale the draft and the published text with the
    release that published it. The status in the API follows from the texts (DRAFT, PUBLISHED, CHANGED; no row is
    MISSING); `invalidated_at` marks a draft whose arguments an import changed.
-   **`V6__create_idempotency_record.sql`**: same as the engine's V19.

## Seed Scripts (`src/main/resources/db/migration/<service>/testdata`)

Version numbers start at 900; see [Seed data](#seed-data) for how they are applied.

-   **engine `V900__seed_users.sql`**: six users with their canonical players, identities, self ghost players and privacy settings.
-   **engine `V901__seed_games.sql`**: ten games and three expansions, with fixed public ids (the game-catalog seeds refer to them).
-   **engine `V902__seed_community.sql`**: a group, a community with members, a pending and a rejected membership request.
-   **engine `V903__seed_playsets.sql`**: four playsets.
-   **engine `V904__seed_ghost_players.sql`**: seven ghost players per user (and one deleted), claim edges for Peter and Nora, a pending claim request and a trusted editor.
-   **engine `V905__seed_matches.sql`**: 520 matches with participants, loadouts and ranks, a dispute and a pending match edit.
-   **game-catalog `V900`–`V902`**: a slice of the BGG ranking, one candidate per pipeline stage and review status, and raw artifacts.
-   **i18n `V900__seed_users.sql`**: two CMS users.
-   **i18n `V901__seed_match_tracker.sql`**: the example app of stratastax-flutter (`match-tracker`, en and nl) with
    eleven keys, one release, a translation in every status, an obsolete key and an invalidated draft.
