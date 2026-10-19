-- Seed data of the game catalog. Every query returns one row per violation.

SELECT 'expected 9 candidates, found ' || count(*) FROM candidate HAVING count(*) <> 9;

SELECT 'expected 9 ranking entries linked to a candidate, found ' || count(*)
FROM bgg_ranking WHERE candidate_id IS NOT NULL HAVING count(*) <> 9;

SELECT 'published candidate without an engine game: ' || display_name
FROM candidate WHERE status = 'PUBLISHED' AND engine_game_id IS NULL;

SELECT 'expected 5 raw artifacts, found ' || count(*) FROM raw_artifact HAVING count(*) <> 5;

SELECT 'expected 4 pipeline steps, found ' || count(*) FROM pipeline_control HAVING count(*) <> 4;
