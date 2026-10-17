-- Where a game or expansion came from, e.g. 'bgg:199792' for a game the game catalog published.
-- Unique, so publishing the same source twice is refused (409) instead of creating a duplicate;
-- the catalog then links its candidate to the existing game. NULL for games entered by hand.
ALTER TABLE game ADD COLUMN source_ref VARCHAR(64);
ALTER TABLE expansion ADD COLUMN source_ref VARCHAR(64);

CREATE UNIQUE INDEX ux_game_source_ref ON game (source_ref);
CREATE UNIQUE INDEX ux_expansion_source_ref ON expansion (source_ref);
