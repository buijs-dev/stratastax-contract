-- Rules for the seed data of every service. Every query returns one row per violation.

-- Seed data sets its own timestamps (2026-01-01 and before), so no row depends on when the database
-- was built. Only the reference data of v1 (pipeline_control) and runtime tables may hold now().
SELECT string_agg(
         format('SELECT %L WHERE EXISTS (SELECT 1 FROM %I WHERE %I > timestamptz %L)',
                'seeded timestamp from now(): ' || table_name || '.' || column_name,
                table_name, column_name, '2026-01-02 00:00+00'),
         ' UNION ALL ')
FROM information_schema.columns
WHERE table_schema = 'public' AND data_type = 'timestamp with time zone'
  AND table_name NOT LIKE 'flyway%' AND table_name NOT IN ('pipeline_control', 'idempotency_record')
\gexec
