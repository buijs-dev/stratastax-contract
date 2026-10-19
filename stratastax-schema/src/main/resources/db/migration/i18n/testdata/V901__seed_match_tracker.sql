-- The example app of stratastax-flutter (examples/match_tracker) in English and Dutch: a slice of its
-- keys, one release, and a translation in every status. The story, in order:
--   2025-12-01  Iris creates the application and imports the keys of en.yaml
--   2025-12-10  Bram translates into Dutch; Iris corrects one English base text
--   2025-12-15  Iris publishes release 1 (en, nl)
--   2025-12-20  a new import drops matchCreateCommand.notes.label (obsolete) and renames the argument
--               of matchCreateCommand.players.count, which invalidates its Dutch draft
--   2025-12-22  Bram writes new Dutch drafts, to be published with release 2

INSERT INTO application (public_id, application_key, display_name, base_locale, created_at, version) VALUES
    ('0192f200-0002-7000-8000-000000000001', 'match-tracker', 'Match tracker', 'en', '2025-12-01 12:00+00', 0);

INSERT INTO application_locale (application_id, locale, added_at)
SELECT a.id, l.locale, timestamptz '2025-12-01 12:00+00'
FROM application a
CROSS JOIN (VALUES ('en'), ('nl')) AS l (locale)
WHERE a.application_key = 'match-tracker';

INSERT INTO message_key (public_id, application_id, message_key, base_text, description, obsoleted_at, created_at, updated_at, version)
SELECT k.public_id::uuid, a.id, k.message_key, k.base_text, k.description, k.obsoleted_at::timestamptz,
       timestamptz '2025-12-01 12:05+00', k.updated_at::timestamptz, k.version
FROM application a
CROSS JOIN (VALUES
    ('0192f200-0003-7000-8000-000000000001', 'app.title',                                    'Match tracker',                 'Title of the app bar', NULL, '2025-12-15 10:00+00', 3),
    ('0192f200-0003-7000-8000-000000000002', 'matchCreateCommand.title',                     'New match',                     NULL, NULL, '2025-12-15 10:00+00', 2),
    ('0192f200-0003-7000-8000-000000000003', 'matchCreateCommand.gameId.label',              'Game',                          NULL, NULL, '2025-12-15 10:00+00', 2),
    ('0192f200-0003-7000-8000-000000000004', 'matchCreateCommand.gameId.hint',               'Search a game…',                'Placeholder of the game search field', NULL, '2025-12-22 14:00+00', 3),
    ('0192f200-0003-7000-8000-000000000005', 'matchCreateCommand.playedAt.label',            'Played at',                     NULL, NULL, '2025-12-22 14:00+00', 1),
    ('0192f200-0003-7000-8000-000000000006', 'matchCreateCommand.players.label',             'Players',                       NULL, NULL, '2025-12-15 10:00+00', 2),
    ('0192f200-0003-7000-8000-000000000007', 'matchCreateCommand.players.count',             '{count, plural, =0 {No players yet} one {# player} other {# players}}',
                                                                                             'Number of players added to the match', NULL, '2025-12-20 08:00+00', 4),
    ('0192f200-0003-7000-8000-000000000008', 'matchCreateCommand.players.winner',            'Winner',                        NULL, NULL, '2025-12-15 10:00+00', 2),
    ('0192f200-0003-7000-8000-000000000009', 'matchCreateCommand.players.remove',            'Remove',                        NULL, NULL, NULL, 0),
    ('0192f200-0003-7000-8000-00000000000a', 'matchCreateCommand.editRequestsEnabled.label', 'Allow others to propose edits', NULL, NULL, '2025-12-22 14:00+00', 1),
    ('0192f200-0003-7000-8000-00000000000b', 'matchCreateCommand.notes.label',               'Notes',                         NULL, '2025-12-20 08:00+00', '2025-12-20 08:00+00', 3)
) AS k (public_id, message_key, base_text, description, obsoleted_at, updated_at, version)
WHERE a.application_key = 'match-tracker';

INSERT INTO message_argument (message_key_id, position, name, argument_type)
SELECT mk.id, 0, 'count', 'NUMBER'
FROM message_key mk
WHERE mk.message_key = 'matchCreateCommand.players.count';

INSERT INTO release (public_id, application_id, release_number, note, message_count, published_at, published_by_user_id, created_at)
SELECT '0192f200-0004-7000-8000-000000000001', a.id, 1, 'First Dutch translation', 9,
       '2025-12-15 10:00+00', u.id, '2025-12-15 10:00+00'
FROM application a
JOIN app_user u ON u.subject = 'seed-cms-user-1'
WHERE a.application_key = 'match-tracker';

INSERT INTO release_locale (release_id, locale)
SELECT r.id, l.locale
FROM release r
CROSS JOIN (VALUES ('en'), ('nl')) AS l (locale)
WHERE r.public_id = '0192f200-0004-7000-8000-000000000001';

-- Status per row: PUBLISHED (only published_text), CHANGED (both texts), DRAFT (only draft_text).
-- matchCreateCommand.players.remove has no translation (MISSING).
INSERT INTO translation (public_id, message_key_id, locale, draft_text, published_text, published_release_id,
                         invalidated_at, updated_by_user_id, created_at, updated_at, version)
SELECT t.public_id::uuid, mk.id, t.locale, t.draft_text, t.published_text,
       CASE WHEN t.published_text IS NOT NULL THEN r.id END,
       t.invalidated_at::timestamptz, u.id, t.created_at::timestamptz, t.updated_at::timestamptz, t.version
FROM (VALUES
    ('0192f200-0005-7000-8000-000000000001', 'app.title', 'en', NULL, 'Match Tracker', NULL,
     'seed-cms-user-1', '2025-12-10 11:00+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-000000000002', 'app.title', 'nl', NULL, 'Wedstrijden', NULL,
     'seed-cms-user-2', '2025-12-10 09:10+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-000000000003', 'matchCreateCommand.title', 'nl', NULL, 'Nieuwe wedstrijd', NULL,
     'seed-cms-user-2', '2025-12-10 09:11+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-000000000004', 'matchCreateCommand.gameId.label', 'nl', NULL, 'Spel', NULL,
     'seed-cms-user-2', '2025-12-10 09:12+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-000000000005', 'matchCreateCommand.gameId.hint', 'nl', 'Zoek een spel op naam…', 'Zoek een spel…', NULL,
     'seed-cms-user-2', '2025-12-10 09:13+00', '2025-12-22 14:00+00', 2),
    ('0192f200-0005-7000-8000-000000000006', 'matchCreateCommand.playedAt.label', 'nl', 'Gespeeld op', NULL, NULL,
     'seed-cms-user-2', '2025-12-22 14:00+00', NULL, 0),
    ('0192f200-0005-7000-8000-000000000007', 'matchCreateCommand.players.label', 'nl', NULL, 'Spelers', NULL,
     'seed-cms-user-2', '2025-12-10 09:14+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-000000000008', 'matchCreateCommand.players.count', 'nl',
     '{n, plural, one {# speler} other {# spelers}}',
     '{count, plural, =0 {Nog geen spelers} one {# speler} other {# spelers}}', '2025-12-20 08:00+00',
     'seed-cms-user-2', '2025-12-10 09:15+00', '2025-12-20 08:00+00', 2),
    ('0192f200-0005-7000-8000-000000000009', 'matchCreateCommand.players.winner', 'nl', NULL, 'Winnaar', NULL,
     'seed-cms-user-2', '2025-12-10 09:16+00', '2025-12-15 10:00+00', 1),
    ('0192f200-0005-7000-8000-00000000000a', 'matchCreateCommand.editRequestsEnabled.label', 'nl', 'Anderen mogen wijzigingen voorstellen', NULL, NULL,
     'seed-cms-user-2', '2025-12-22 14:00+00', NULL, 0),
    ('0192f200-0005-7000-8000-00000000000b', 'matchCreateCommand.notes.label', 'nl', NULL, 'Notities', NULL,
     'seed-cms-user-2', '2025-12-10 09:17+00', '2025-12-15 10:00+00', 1)
) AS t (public_id, message_key, locale, draft_text, published_text, invalidated_at, subject, created_at, updated_at, version)
JOIN message_key mk ON mk.message_key = t.message_key
JOIN app_user u ON u.subject = t.subject
JOIN release r ON r.public_id = '0192f200-0004-7000-8000-000000000001';
