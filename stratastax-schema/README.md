# Stratastax Schema

This module contains the database schema definitions and migration scripts for the Stratastax platform.

## Infrastructure & Deployment

### Docker Entrypoint (`src/main/docker/entrypoint.sh`)
The Docker image uses a custom entrypoint that runs a single Flyway migration against `filesystem:/flyway/migrations` with up to 10 connection retries and `baselineOnMigrate=true`.
- **Configuration**: Connection details are supplied via environment variables (`FLYWAY_URL`, `FLYWAY_USER`, `FLYWAY_PASSWORD`).

## Schema Migrations (`src/main/resources/db/migration/v1`)

These scripts define the core Stratastax domain model.

### Core Entities

-   **`V1__create_user.sql`**: Defines the `app_user` table. The "app_" prefix is used because "user" is a reserved keyword in PostgreSQL. Users own Credentials and PrivacySettings.
-   **`V2__user_identity.sql`**: Stores authentication methods (password, OAuth, etc.) linked to a User.
-   **`V3__create_canonical_player.sql`**: The authoritative identity anchor for gaming history, created during user registration.
-   **`V4__create_ghost_player.sql`**: Personal, reusable player references kept by match recorders. Unlike CanonicalPlayers, GhostPlayers are not globally unique.
-   **`V5__create_game.sql`**: Catalogue of games. It is independent of external sources like BGG.
-   **`V6__create_expansion.sql`**: Child entity of a Game; has no meaning on its own.
-   **`V7__create_group.sql`**: Named rosters of Users (`app_group`). The "app_" prefix is used because "GROUP" is a reserved keyword.
-   **`V8__create_playset.sql`**: Shared match configurations for specific games.
-   **`V9__create_community.sql`**: Shared identity and history for sets of Users.
-   **`V10__create_membership_request.sql`**: Pending requests to join a Community.

### Match & Gaming History

-   **`V11__create_match.sql`**: The aggregate root for gaming history.
-   **`V13__create_match_participant.sql`**: Records a player's role and result in a Match. References GhostPlayers.
-   **`V12__create_match_loadout.sql`**: Per-player configuration (faction, character, etc.) for a match participant.
-   **`V14__create_claim_request.sql`**: Proposed links between a CanonicalPlayer and GhostPlayers.
-   **`V15__create_claim_edge.sql`**: The approved, revocable relationship between a CanonicalPlayer and a GhostPlayer.
-   **`V16__create_match_edit.sql`**: Proposed changes to recorded Matches. Uses three fully normalized child tables rather than a JSONB blob: `match_edit_participant_change` (score/rank/outcome), `match_edit_loadout_change` (loadout attributes), and `match_edit_playset_change` (Playset reference). The change set is a genuine closed set, so FK-validated tables are both more explicit and no larger than a JSONB approach.
-   **`V17__create_trusted_editor.sql`**: Allows a Match owner to auto-approve edits from specific users.

### Privacy

-   **`V18__create_privacy_setting.sql`**: Manages privacy levels for different data types and controls privileged access for groups. Default is `PRIVATE`.

## Testdata Migrations (`src/main/resources/db/migration/testdata`)

These scripts seed reference data for local development and testing. They use version numbers in the 900 range to avoid collisions with production migrations.

-   **`V900__seed_users.sql`**: Seed users.
-   **`V901__seed_games.sql`**: Seed games.
-   **`V902__seed_community.sql`**: Seed communities.
-   **`V903__seed_playsets.sql`**: Seed playsets.
-   **`V904__seed_ghost_players.sql`**: Seed ghost players.
-   **`V905__seed_matches.sql`**: Seed matches.
