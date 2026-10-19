-- A slice of the BGG ranking CSV: base games and expansions (rank 0: not ranked by BGG).
-- Deterministic like the engine seed data: fixed public ids and timestamps.
INSERT INTO bgg_ranking (public_id, bgg_id, display_name, year_published, rank, is_expansion, created_at)
SELECT format('0192f100-0002-7000-8000-%s', lpad(to_hex(r.n), 12, '0'))::uuid,
       r.bgg_id, r.display_name, r.year_published, r.rank, r.is_expansion, timestamptz '2025-12-01 12:00+00'
FROM (VALUES
    ( 1, 224517, 'Brass: Birmingham',            2018,   1, false),
    ( 2, 169786, 'Scythe',                       2016,  16, false),
    ( 3, 199792, 'Everdell',                     2018,  41, false),
    ( 4, 266192, 'Wingspan',                     2019,  37, false),
    ( 5, 237182, 'Root',                         2018,  28, false),
    ( 6,  30549, 'Pandemic',                     2008, 118, false),
    ( 7, 178900, 'Codenames',                    2015, 110, false),
    ( 8,  68448, '7 Wonders',                    2010,  82, false),
    ( 9, 199727, 'Scythe: Invaders from Afar',   2016,   0, true),
    (10, 259996, 'Everdell: Pearlbrook',         2019,   0, true),
    (11, 291457, 'Gloomhaven: Jaws of the Lion', 2020,   5, false),
    (12, 161936, 'Pandemic Legacy: Season 1',    2015,  10, false)
) AS r (n, bgg_id, display_name, year_published, rank, is_expansion);
