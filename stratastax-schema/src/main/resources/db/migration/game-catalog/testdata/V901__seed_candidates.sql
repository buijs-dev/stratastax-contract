-- One candidate per pipeline stage and review status. Scythe was published to the engine: its
-- engine_game_id is the fixed public id of Scythe in the engine seed data (engine V901).
INSERT INTO candidate (public_id, bgg_id, display_name, description, min_players, max_players, playing_time, min_age, year_published,
                       image_url, tags, is_expansion, base_game_bgg_id, score_type, win_condition, stage, status, reliability,
                       failure_reason, publish_request_id, engine_game_id, created_at, version) VALUES
    ('0192f100-0000-7000-8000-000000000001', 169786, 'Scythe',
     'An alternate-history 1920s Europa strategy game.', 1, 5, 115, 14, 2016, NULL, ARRAY['Economic', 'Territory Building'],
     false, NULL, 'SCORE', 'HIGHER_WINS', 'INTERPRETED', 'PUBLISHED', 'HIGH',
     NULL, '0192f100-0000-7000-8000-0000000000a1', '0192f000-0000-7000-8000-000000000001', '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000002', 199792, 'Everdell',
     'Within the charming valley of Everdell, critters build a city of buildings and creatures.', 1, 4, 80, 13, 2018, NULL, ARRAY['Animals', 'Worker Placement'],
     false, NULL, 'SCORE', 'HIGHER_WINS', 'INTERPRETED', 'PENDING', 'HIGH',
     NULL, NULL, NULL, '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000003', 199727, 'Scythe: Invaders from Afar',
     'Adds two new factions to Scythe.', 1, 7, 115, 14, 2016, NULL, ARRAY['Expansion for Base-game'],
     true, 169786, 'SCORE', 'HIGHER_WINS', 'INTERPRETED', 'PENDING', 'MEDIUM',
     NULL, NULL, NULL, '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000004', 30549, 'Pandemic',
     'Four diseases have broken out in the world and it is up to a team of specialists to find cures.', 2, 4, 45, 8, 2008, NULL, ARRAY['Medical', 'Cooperative'],
     false, NULL, 'WIN_LOSS', NULL, 'INTERPRETED', 'PENDING', 'LOW',
     NULL, NULL, NULL, '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000005', 224517, 'Brass: Birmingham',
     'Build networks, grow industries and navigate the world of the Industrial Revolution.', 2, 4, 120, 14, 2018, NULL, ARRAY['Economic', 'Industry / Manufacturing'],
     false, NULL, 'SCORE', 'HIGHER_WINS', 'INTERPRETED', 'APPROVED', 'HIGH',
     NULL, '0192f100-0000-7000-8000-0000000000a5', NULL, '2025-12-01 13:00+00', 1),
    ('0192f100-0000-7000-8000-000000000006', 266192, 'Wingspan',
     'Attract a beautiful and diverse collection of birds to your wildlife preserve.', 1, 5, 70, 10, 2019, NULL, ARRAY['Animals', 'Card Game'],
     false, NULL, NULL, NULL, 'RULES_COLLECTED', 'PENDING', 'UNVERIFIED', NULL, NULL, NULL, '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000007', 237182, 'Root',
     'Decide the fate of the forest as woodland factions fight for contrasting goals.', 2, 4, 90, 10, 2018, NULL, ARRAY['Animals', 'Wargame'],
     false, NULL, NULL, NULL, 'PENDING_RULES', 'PENDING', 'UNVERIFIED', NULL, NULL, NULL, '2025-12-01 13:00+00', 0),
    ('0192f100-0000-7000-8000-000000000008', 178900, 'Codenames',
     'Give your team clever one-word clues to help them spot their agents in the field.', 2, 8, 15, 14, 2015, NULL, ARRAY['Party Game', 'Word Game'],
     false, NULL, 'WIN_LOSS', NULL, 'INTERPRETED', 'REJECTED', 'MEDIUM', NULL, NULL, NULL, '2025-12-01 13:00+00', 1),
    ('0192f100-0000-7000-8000-000000000009', 68448, '7 Wonders',
     NULL, NULL, NULL, NULL, NULL, 2010, NULL, '{}',
     false, NULL, NULL, NULL, 'FAILED', 'PENDING', 'UNVERIFIED', 'No rulebook content found for ''7 Wonders''', NULL, NULL, '2025-12-01 13:00+00', 0);

UPDATE bgg_ranking r
SET candidate_id = c.id, updated_at = c.created_at
FROM candidate c
WHERE c.bgg_id = r.bgg_id;

INSERT INTO candidate_reliability_check (public_id, candidate_id, field, bgg_value, llm_value, matches, created_at)
SELECT format('0192f100-0003-7000-8000-%s', lpad(to_hex(v.n), 12, '0'))::uuid,
       c.id, v.field, v.bgg_value, v.llm_value, v.matches, c.created_at
FROM (VALUES
    ( 1, 169786, 'minPlayers',    '1',    '1',    true),
    ( 2, 169786, 'maxPlayers',    '5',    '5',    true),
    ( 3, 169786, 'yearPublished', '2016', '2016', true),
    ( 4, 199792, 'minPlayers',    '1',    '1',    true),
    ( 5, 199792, 'maxPlayers',    '4',    '4',    true),
    ( 6, 199792, 'playingTime',   '80',   '80',   true),
    ( 7, 199727, 'maxPlayers',    '7',    '7',    true),
    ( 8,  30549, 'minPlayers',    '2',    '1',    false),
    ( 9,  30549, 'maxPlayers',    '4',    '4',    true),
    (10, 224517, 'minPlayers',    '2',    '2',    true),
    (11, 224517, 'maxPlayers',    '4',    '4',    true),
    (12, 224517, 'minAge',        '14',   '14',   true)
) AS v (n, bgg_id, field, bgg_value, llm_value, matches)
JOIN candidate c ON c.bgg_id = v.bgg_id;
