INSERT INTO playset (owner_user_id, game_id, display_name, variants, scenario, version)
SELECT u.id, g.id, 'Our Scythe Setup', ARRAY['Automa'], NULL, 0
FROM app_user u, game g
WHERE u.display_name = 'Emma' AND g.name = 'Scythe';

INSERT INTO playset (owner_user_id, game_id, display_name, variants, scenario, version)
SELECT u.id, g.id, 'Competitive Root', ARRAY['Vagabond Errata'], 'Autumn', 0
FROM app_user u, game g
WHERE u.display_name = 'Ruud' AND g.name = 'Root';

INSERT INTO playset (owner_user_id, game_id, display_name, variants, scenario, version)
SELECT u.id, g.id, 'Relaxed Wingspan', ARRAY[]::TEXT[], NULL, 0
FROM app_user u, game g
WHERE u.display_name = 'Sara' AND g.name = 'Wingspan';

INSERT INTO playset_expansion (playset_id, expansion_id)
SELECT p.id, e.id
FROM playset p
JOIN expansion e ON e.game_id = p.game_id AND e.name = 'Invaders from Afar'
WHERE p.display_name = 'Our Scythe Setup';

INSERT INTO playset (owner_user_id, game_id, display_name, variants, scenario, version)
SELECT u.id, g.id, 'Everdell with Pearlbrook', ARRAY[]::TEXT[], NULL, 0
FROM app_user u, game g
WHERE u.display_name = 'Alain' AND g.name = 'Everdell';

INSERT INTO playset_expansion (playset_id, expansion_id)
SELECT p.id, e.id
FROM playset p
JOIN expansion e ON e.game_id = p.game_id AND e.name = 'Pearlbrook'
WHERE p.display_name = 'Everdell with Pearlbrook';
