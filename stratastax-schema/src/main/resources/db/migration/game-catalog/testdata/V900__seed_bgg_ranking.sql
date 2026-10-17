-- A slice of the BGG ranking CSV: base games and expansions, ranked.
INSERT INTO bgg_ranking (bgg_id, name, year_published, rank, is_expansion) VALUES
    (224517, 'Brass: Birmingham',              2018,    1, false),
    (169786, 'Scythe',                         2016,   16, false),
    (199792, 'Everdell',                       2018,   41, false),
    (266192, 'Wingspan',                       2019,   37, false),
    (237182, 'Root',                           2018,   28, false),
    ( 30549, 'Pandemic',                       2008,  118, false),
    (178900, 'Codenames',                      2015,  110, false),
    ( 68448, '7 Wonders',                      2010,   82, false),
    (199727, 'Scythe: Invaders from Afar',     2016,    0, true),
    (259996, 'Everdell: Pearlbrook',           2019,    0, true),
    (291457, 'Gloomhaven: Jaws of the Lion',   2020,    5, false),
    (161936, 'Pandemic Legacy: Season 1',      2015,   10, false);
