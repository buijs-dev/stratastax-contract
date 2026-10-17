INSERT INTO playset (public_id, owner_user_id, game_id, display_name, variants, scenario, created_at, version)
SELECT p.public_id::uuid, u.id, g.id, p.display_name, p.variants, p.scenario, timestamptz '2025-11-20 12:00+00', 0
FROM (VALUES
    ('0192f000-0006-7000-8000-000000000001', 'Emma',  'Scythe',   'Our Scythe Setup',         ARRAY['Automa'],          NULL),
    ('0192f000-0006-7000-8000-000000000002', 'Ruud',  'Root',     'Competitive Root',         ARRAY['Vagabond Errata'], 'Autumn'),
    ('0192f000-0006-7000-8000-000000000003', 'Sara',  'Wingspan', 'Relaxed Wingspan',         ARRAY[]::TEXT[],          NULL),
    ('0192f000-0006-7000-8000-000000000004', 'Alain', 'Everdell', 'Everdell with Pearlbrook', ARRAY[]::TEXT[],          NULL)
) AS p (public_id, owner, game_name, display_name, variants, scenario)
JOIN app_user u ON u.display_name = p.owner
JOIN game g ON g.display_name = p.game_name;

INSERT INTO playset_expansion (playset_id, expansion_id)
SELECT p.id, e.id
FROM (VALUES
    ('Our Scythe Setup',         'Invaders from Afar'),
    ('Everdell with Pearlbrook', 'Pearlbrook')
) AS pe (playset_name, expansion_name)
JOIN playset p ON p.display_name = pe.playset_name
JOIN expansion e ON e.game_id = p.game_id AND e.display_name = pe.expansion_name;
