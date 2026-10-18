-- Seed data of the i18n service. Every query returns one row per violation.

SELECT 'expected 11 message keys, found ' || count(*) FROM message_key HAVING count(*) <> 11;
SELECT 'expected 1 obsolete message key, found ' || count(*) FROM message_key WHERE obsoleted_at IS NOT NULL HAVING count(*) <> 1;
SELECT 'expected 11 translations, found ' || count(*) FROM translation HAVING count(*) <> 11;

-- Every status of the API occurs: MISSING (a key without a translation), DRAFT, PUBLISHED and CHANGED.
SELECT 'no translation with status ' || s.status
FROM (VALUES ('DRAFT'), ('PUBLISHED'), ('CHANGED')) AS s (status)
WHERE NOT EXISTS (
    SELECT 1 FROM translation t
    WHERE s.status = CASE
        WHEN t.draft_text IS NOT NULL AND t.published_text IS NOT NULL THEN 'CHANGED'
        WHEN t.draft_text IS NOT NULL THEN 'DRAFT'
        ELSE 'PUBLISHED' END
);
SELECT 'no message key without a translation (MISSING)'
WHERE NOT EXISTS (SELECT 1 FROM message_key mk WHERE NOT EXISTS (SELECT 1 FROM translation t WHERE t.message_key_id = mk.id));
SELECT 'expected 1 invalidated translation, found ' || count(*) FROM translation WHERE invalidated_at IS NOT NULL HAVING count(*) <> 1;

-- The invariants of the application that the seed data must respect as well.
SELECT 'base locale not among the locales of ' || a.application_key
FROM application a
WHERE NOT EXISTS (SELECT 1 FROM application_locale al WHERE al.application_id = a.id AND al.locale = a.base_locale);

SELECT 'translation in a locale that its application lacks: ' || mk.message_key || ' ' || t.locale
FROM translation t
JOIN message_key mk ON mk.id = t.message_key_id
WHERE NOT EXISTS (SELECT 1 FROM application_locale al WHERE al.application_id = mk.application_id AND al.locale = t.locale);

SELECT 'translation published by a release of another application: ' || mk.message_key || ' ' || t.locale
FROM translation t
JOIN message_key mk ON mk.id = t.message_key_id
JOIN release r ON r.id = t.published_release_id
WHERE r.application_id <> mk.application_id;

SELECT 'release ' || r.release_number || ' published ' || count(t.id) || ' translations, message_count says ' || r.message_count
FROM release r
LEFT JOIN translation t ON t.published_release_id = r.id
GROUP BY r.id
HAVING count(t.id) <> r.message_count;
