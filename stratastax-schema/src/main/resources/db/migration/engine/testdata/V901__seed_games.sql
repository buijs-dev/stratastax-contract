-- Fixed public ids, so the game-catalog seed data can refer to these games
-- (a catalog candidate that was published to the engine keeps the engine id).
INSERT INTO game (public_id, name, description, min_players, max_players, score_type, win_condition, tags, version, source_ref) VALUES
    ('0192f000-0000-7000-8000-000000000001', 'Scythe',            'An alternate-history 1920s Europa strategy game.', 1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building', 'Area Control'], 0, 'bgg:169786'),
    ('0192f000-0000-7000-8000-000000000002', 'Everdell',          'A worker-placement game set in a woodland realm.',  1, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Worker Placement', 'Tableau Building'], 0, 'bgg:199792'),
    ('0192f000-0000-7000-8000-000000000003', 'Wingspan',          'A competitive bird-collection engine builder.',     1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building'], 0, 'bgg:266192'),
    ('0192f000-0000-7000-8000-000000000004', 'Root',              'An asymmetric woodland war game.',                 2, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Area Control', 'Asymmetric'], 0, 'bgg:237182'),
    ('0192f000-0000-7000-8000-000000000005', '7 Wonders',         'A civilization drafting game.',                    3, 7, 'SCORE',    'HIGHER_WINS', ARRAY['Drafting'], 0, 'bgg:68448'),
    ('0192f000-0000-7000-8000-000000000006', 'Codenames',         'A team word-association guessing game.',           4, 8, 'WIN_LOSS', NULL,          ARRAY['Party', 'Word Game'], 0, 'bgg:178900'),
    ('0192f000-0000-7000-8000-000000000007', 'The Crew',          'A cooperative trick-taking space adventure.',      3, 5, 'WIN_LOSS', NULL,          ARRAY['Cooperative', 'Trick-Taking'], 0, NULL),
    ('0192f000-0000-7000-8000-000000000008', 'Pandemic',          'A cooperative disease-outbreak game.',             2, 4, 'WIN_LOSS', NULL,          ARRAY['Cooperative'], 0, 'bgg:30549'),
    ('0192f000-0000-7000-8000-000000000009', 'Fast Sprint Racer', 'A real-time dexterity racing game.',               1, 6, 'TIME',     'LOWER_WINS',  ARRAY['Dexterity', 'Racing'], 0, NULL),
    ('0192f000-0000-7000-8000-000000000010', 'Turn Limit Tactics','A tactical skirmish game won by efficiency.',      2, 4, 'TURNS',    'LOWER_WINS',  ARRAY['Tactical'], 0, NULL);

-- A couple of expansions, for use by seeded Playsets.
INSERT INTO expansion (public_id, game_id, name, description, version, source_ref)
SELECT '0192f000-0000-7000-8000-000000000101', id, 'Invaders from Afar', 'Adds two new factions to Scythe.', 0, 'bgg:199727' FROM game WHERE name = 'Scythe';
INSERT INTO expansion (public_id, game_id, name, description, version)
SELECT '0192f000-0000-7000-8000-000000000102', id, 'The Wind Gambit', 'Adds airships to Scythe.', 0 FROM game WHERE name = 'Scythe';
INSERT INTO expansion (public_id, game_id, name, description, version, source_ref)
SELECT '0192f000-0000-7000-8000-000000000103', id, 'Pearlbrook', 'Adds a river to Everdell.', 0, 'bgg:259996' FROM game WHERE name = 'Everdell';
