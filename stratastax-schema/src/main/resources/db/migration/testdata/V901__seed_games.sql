INSERT INTO game (name, description, min_players, max_players, score_type, win_condition, tags, version) VALUES
    ('Scythe',            'An alternate-history 1920s Europa strategy game.', 1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building', 'Area Control'], 0),
    ('Everdell',          'A worker-placement game set in a woodland realm.',  1, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Worker Placement', 'Tableau Building'], 0),
    ('Wingspan',          'A competitive bird-collection engine builder.',     1, 5, 'SCORE',    'HIGHER_WINS', ARRAY['Engine Building'], 0),
    ('Root',              'An asymmetric woodland war game.',                 2, 4, 'SCORE',    'HIGHER_WINS', ARRAY['Area Control', 'Asymmetric'], 0),
    ('7 Wonders',         'A civilization drafting game.',                    3, 7, 'SCORE',    'HIGHER_WINS', ARRAY['Drafting'], 0),
    ('Codenames',         'A team word-association guessing game.',           4, 8, 'WIN_LOSS', NULL,          ARRAY['Party', 'Word Game'], 0),
    ('The Crew',          'A cooperative trick-taking space adventure.',      3, 5, 'WIN_LOSS', NULL,          ARRAY['Cooperative', 'Trick-Taking'], 0),
    ('Pandemic',          'A cooperative disease-outbreak game.',             2, 4, 'WIN_LOSS', NULL,          ARRAY['Cooperative'], 0),
    ('Fast Sprint Racer', 'A real-time dexterity racing game.',               1, 6, 'TIME',     'LOWER_WINS',  ARRAY['Dexterity', 'Racing'], 0),
    ('Turn Limit Tactics','A tactical skirmish game won by efficiency.',      2, 4, 'TURNS',    'LOWER_WINS',  ARRAY['Tactical'], 0);

-- A couple of expansions, for use by seeded Playsets.
INSERT INTO expansion (game_id, name, description, version)
SELECT id, 'Invaders from Afar', 'Adds two new factions to Scythe.', 0 FROM game WHERE name = 'Scythe';
INSERT INTO expansion (game_id, name, description, version)
SELECT id, 'The Wind Gambit', 'Adds airships to Scythe.', 0 FROM game WHERE name = 'Scythe';
INSERT INTO expansion (game_id, name, description, version)
SELECT id, 'Pearlbrook', 'Adds a river to Everdell.', 0 FROM game WHERE name = 'Everdell';
