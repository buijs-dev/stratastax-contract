# Cross-Aggregate Invariants — Intentionally Not Enforced by the Database

Per the Persistence Modeling Guidelines ("model persistence for data
storage, not for business logic" — persistence is an adapter, isolated
from the domain), this schema deliberately does **not** use triggers or
stored procedures to enforce invariants that span more than one aggregate.
Doing so would push business rules into the persistence layer, which the
Engineering Philosophy and Persistence Modeling Guidelines both rule out.

Single-aggregate invariants (e.g. "MinPlayers <= MaxPlayers" on `game`,
"at most one active claim_edge per ghost_player") **are** enforced by the
database via CHECK constraints and unique indexes — those are storage-
level facts, not business logic crossing an aggregate boundary.

The following invariants are enforced by the application/domain layer
only. Each is also noted as a `COMMENT ON TABLE` at its point of origin
in the migrations, for visibility when reading the schema directly.

| Invariant | Tables involved | Enforced by |
|---|---|---|
| A Match's `playset_id`, if set, must reference a Playset with the same `game_id` as the Match | `match`, `playset` | Match aggregate (on create/update) |
| `Community.admin_group_id`, if set, must be owned by `Community.owner_user_id`; transferring ownership clears it | `community`, `app_group` | Community aggregate (on ownership transfer / admin group change) |
| `MembershipRequest.decided_by_user_id` must be the target Community's owner or a member of its admin_group | `membership_request`, `community`, `membership` | MembershipRequest approval command |
| `MatchEdit.approved_by_user_id` must equal the target Match's `recorder_user_id` | `match_edit`, `match` | MatchEdit approval command |
| Every Group referenced by a PrivacySetting must be owned by the same User as the PrivacySetting | `privacy_setting_group`, `app_group`, `privacy_setting` | PrivacySetting aggregate (on grant) |
| A User cannot remove their last remaining identity link | `app_user_identity`, `app_user` | User aggregate (on identity link removal) |
| Removing a member who holds admin rights (a member of `admin_group_id`) requires being the Community's owner; any admin may remove a non-admin member | `membership`, `community`, `app_group` | Community aggregate (on member removal) |
| If a removed/leaving member held admin rights, they are also removed from the Community's `admin_group_id` Group | `membership`, `community`, `group_member` | Community aggregate (on member removal/leave) |
| A soft-deleted `app_group` (or `playset`, `community`) grants/references nothing further, even though the row still exists | `app_group`, `playset`, `community`, and everything referencing them | Every read path that resolves access or displays these references |

If any of these ever need to be queried directly (not just enforced on
write), that is a signal to revisit whether it belongs in the database
after all — not a reason to add a trigger silently.
