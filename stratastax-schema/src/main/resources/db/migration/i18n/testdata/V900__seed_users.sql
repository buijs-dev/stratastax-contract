-- Seed data is deterministic: fixed public ids and fixed timestamps, no random() or now(), so every
-- database built from these scripts holds exactly the same data. Public ids follow
-- 0192f200-<kind>-7000-8000-<n>, with one <kind> per table:
--   0001 app_user   0002 application   0003 message_key   0004 release   0005 translation
-- Every timestamp is on or before 2026-01-01 12:00 UTC.

-- Two CMS users; the subjects are made up and match no identity provider.
INSERT INTO app_user (public_id, subject, display_name, created_at, version) VALUES
    ('0192f200-0001-7000-8000-000000000001', 'seed-cms-user-1', 'Iris', '2025-12-01 12:00+00', 0),
    ('0192f200-0001-7000-8000-000000000002', 'seed-cms-user-2', 'Bram', '2025-12-10 09:00+00', 0);
