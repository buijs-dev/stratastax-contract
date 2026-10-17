-- Fixed public ids, so the game-catalog seed data can refer to these games
-- (a catalog candidate that was published to the engine keeps the engine id).
INSERT INTO game (public_id, display_name, description, min_players, max_players, score_type, win_condition, tags, source_ref, created_at, version) VALUES
    ('0192f000-0000-7000-8000-000000000001', 'Scythe',             'An alternate-history 1920s Europa strategy game.', 1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building', 'Area Control'],      'bgg:169786', '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000002', 'Everdell',           'A worker-placement game set in a woodland realm.',  1, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Worker Placement', 'Tableau Building'], 'bgg:199792', '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000003', 'Wingspan',           'A competitive bird-collection engine builder.',     1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building'],                      'bgg:266192', '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000004', 'Root',               'An asymmetric woodland war game.',                  2, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Area Control', 'Asymmetric'],           'bgg:237182', '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000005', '7 Wonders',          'A civilization drafting game.',                     3, 7, 'SCORE',    'HIGHER_WINS', ARRAY['Drafting'],                             'bgg:68448',  '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000006', 'Codenames',          'A team word-association guessing game.',            4, 8, 'WIN_LOSS', NULL,          ARRAY['Party', 'Word Game'],                   'bgg:178900', '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000007', 'The Crew',           'A cooperative trick-taking space adventure.',       3, 5, 'WIN_LOSS', NULL,          ARRAY['Cooperative', 'Trick-Taking'],          NULL,         '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000008', 'Pandemic',           'A cooperative disease-outbreak game.',              2, 4, 'WIN_LOSS', NULL,          ARRAY['Cooperative'],                          'bgg:30549',  '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000009', 'Fast Sprint Racer',  'A real-time dexterity racing game.',                1, 6, 'TIME',     'LOWER_WINS',  ARRAY['Dexterity', 'Racing'],                  NULL,         '2025-10-01 12:00+00', 0),
    ('0192f000-0000-7000-8000-000000000010', 'Turn Limit Tactics', 'A tactical skirmish game won by efficiency.',       2, 4, 'TURNS',    'LOWER_WINS',  ARRAY['Tactical'],                             NULL,         '2025-10-01 12:00+00', 0);

-- A couple of expansions, for use by seeded Playsets and match edits.
INSERT INTO expansion (public_id, game_id, display_name, description, source_ref, created_at, version)
SELECT e.public_id::uuid, g.id, e.display_name, e.description, e.source_ref, timestamptz '2025-10-01 12:00+00', 0
FROM (VALUES
    ('0192f000-0000-7000-8000-000000000101', 'Scythe',   'Invaders from Afar', 'Adds two new factions to Scythe.', 'bgg:199727'),
    ('0192f000-0000-7000-8000-000000000102', 'Scythe',   'The Wind Gambit',    'Adds airships to Scythe.',         NULL),
    ('0192f000-0000-7000-8000-000000000103', 'Everdell', 'Pearlbrook',         'Adds a river to Everdell.',        'bgg:259996')
) AS e (public_id, game_name, display_name, description, source_ref)
JOIN game g ON g.display_name = e.game_name;
