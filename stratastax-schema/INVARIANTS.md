# Cross-Aggregate Invariants — Intentionally Not Enforced by the Database

Per the Persistence Modeling Guidelines ("model persistence for data storage, not for business
logic"; persistence is an adapter, isolated from the domain), this schema deliberately does **not**
use triggers or stored procedures to enforce invariants that span more than one row or aggregate.
Doing so would push business rules into the persistence layer, which the Engineering Philosophy and
Persistence Modeling Guidelines both rule out.

Single-row and single-table facts **are** enforced by the database, through CHECK constraints and
(partial) unique indexes: "min_players <= max_players" on `game`, "at most one active claim edge per
ghost player", "a self ghost player is never deleted", "at most one pending membership request per
user and community", "a decided request has a decided_at". Those are storage-level facts, not
business logic crossing an aggregate boundary.

The invariants below are enforced by the application only. Each is also stated in a
`COMMENT ON TABLE` of the table it starts at, so it is visible in the published schema docs.

| Invariant                                                                                                                                                         | Tables involved                                                          | Enforced by                                                        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|--------------------------------------------------------------------|
| A Match's `playset_id`, if set, references a Playset with the same `game_id` as the Match; its expansions belong to that game                                     | `match`, `playset`, `match_expansion`, `expansion`                       | Match aggregate (on create/update)                                 |
| A Playset's expansions belong to its game                                                                                                                         | `playset_expansion`, `expansion`, `playset`                              | Playset aggregate                                                  |
| While a Match is DRAFT, a participant that is removed is deleted (with its loadout); participants are soft-deleted only together with their match                | `match`, `match_participant`, `match_loadout`                            | Match aggregate (on update/delete)                                 |
| `Community.admin_group_id`, if set, is owned by `Community.owner_user_id`; transferring ownership clears it                                                        | `community`, `app_group`                                                 | Community aggregate (on ownership transfer / admin group change)   |
| `MembershipRequest.decided_by_user_id` is the target Community's owner or a member of its admin group                                                             | `membership_request`, `community`, `group_member`                        | MembershipRequest decision command                                 |
| Removing a member who holds admin rights requires being the Community's owner; any admin may remove a non-admin member                                            | `membership`, `community`, `app_group`                                   | Community aggregate (on member removal)                            |
| If a removed/leaving member held admin rights, they are also removed from the Community's admin group                                                             | `membership`, `community`, `group_member`                                | Community aggregate (on member removal/leave)                      |
| `MatchEdit.decided_by_user_id` is the target Match's `recorder_user_id`                                                                                           | `match_edit`, `match`                                                    | MatchEdit decision command                                         |
| A match edit only changes participants of its own match; its new playset is for the match's game and its new expansions belong to it                              | `match_edit`, `match_edit_*_change`, `match_participant`, `playset`      | MatchEdit proposal command                                         |
| Only the fields flagged `*_set` are written when a match edit is approved                                                                                         | `match_edit`, `match_edit_participant_change`, `match_participant`       | MatchEdit decision command                                         |
| A dispute on a participant is raised (and withdrawn) by a user whose canonical player has an active claim edge to the participant's ghost player                  | `match_participant`, `claim_edge`, `app_user`                            | Dispute command                                                    |
| A dispute is cleared when an approved match edit changes the disputed participant                                                                                 | `match_participant`, `match_edit_participant_change`                     | MatchEdit decision command                                         |
| Every Group referenced by a PrivacySetting is owned by the same User as the PrivacySetting                                                                        | `privacy_setting_group`, `app_group`, `privacy_setting`                  | PrivacySetting aggregate (on update)                               |
| Every User has exactly one PrivacySetting per data type (PROFILE, MATCH_HISTORY, MATCH_DETAILS), created PRIVATE together with the user and never deleted         | `privacy_setting`, `app_user`                                            | User registration; there is no command to create or delete one     |
| A User cannot remove their last remaining identity                                                                                                                | `app_user_identity`, `app_user`                                          | User aggregate (on identity removal)                               |
| Every User has a self ghost player with a claim edge to their own canonical player; that claim edge is never revoked                                              | `ghost_player`, `claim_edge`, `app_user`                                 | User registration and the ClaimEdge revoke command                 |
| Deleting a ghost player revokes its active claim edges; a deleted ghost player is not listed or suggested and cannot be used in new matches or claim requests     | `ghost_player`, `claim_edge`, `match_participant`, `claim_request_target` | GhostPlayer delete command and every command that takes one        |
| A soft-deleted `app_group` (or `playset`, `community`) grants or offers nothing further, even though the row still exists                                         | `app_group`, `playset`, `community`, and everything referencing them     | Every read path that resolves access or displays these references  |
| The base locale of an Application is one of its locales | `application`, `application_locale` | Application aggregate (on create/update) |
| A Translation's locale is one of the locales of the application of its key; its text only uses the arguments of its key | `translation`, `message_key`, `application_locale`, `message_argument` | Translation update command |
| A Release publishes only locales of its application, never a draft of an obsolete key or an invalidated draft, and `message_count` is the number of drafts it published | `release`, `release_locale`, `translation`, `message_key` | Release publish command |
| An obsolete message key is left out of every bundle, although its published translations still exist | `message_key`, `translation` | The bundle read path |
| `message_key.version` goes up with every change of one of its translations (it is the ETag of the key with its translations) | `message_key`, `translation` | Translation update and discard commands |
