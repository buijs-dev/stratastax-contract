-- Rules of NAMING.md that the database can check. Every query returns one row per violation.

-- A foreign key is declared once.
SELECT 'duplicate foreign key: ' || conrelid::regclass || ' ' || string_agg(conname, ', ')
FROM pg_constraint
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
GROUP BY conrelid, conkey, confrelid
HAVING count(*) > 1;

-- A foreign key never points at a public_id: references go through the internal BIGINT id.
SELECT 'foreign key on public_id: ' || c.conname
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.confrelid AND a.attnum = ANY (c.confkey)
WHERE c.contype = 'f' AND c.connamespace = 'public'::regnamespace AND a.attname = 'public_id';

-- Every foreign key column is the leading column of an index (a primary key or unique index counts).
SELECT 'foreign key without index: ' || c.conname
FROM pg_constraint c
WHERE c.contype = 'f' AND c.connamespace = 'public'::regnamespace
  AND NOT EXISTS (
      SELECT 1
      FROM pg_index i
      WHERE i.indrelid = c.conrelid
        AND (string_to_array(i.indkey::text, ' '))[1:array_length(c.conkey, 1)] = c.conkey::text[]
  );

-- Constraints are named fk_/uq_/chk_<table>_..., primary keys keep their default name.
SELECT 'constraint not named by convention: ' || conrelid::regclass || '.' || conname
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
  AND contype IN ('f', 'u', 'c')
  AND conname !~ ('^' || CASE contype WHEN 'f' THEN 'fk' WHEN 'u' THEN 'uq' ELSE 'chk' END
                  || '_' || (conrelid::regclass)::text || '_');

-- Indexes that are not a constraint are named ix_<table>_... or, when unique, uq_<table>_...
SELECT 'index not named by convention: ' || i.indexrelid::regclass
FROM pg_index i
JOIN pg_class t ON t.oid = i.indrelid
WHERE t.relnamespace = 'public'::regnamespace
  AND t.relname NOT LIKE 'flyway%'
  AND NOT EXISTS (SELECT 1 FROM pg_constraint c WHERE c.conindid = i.indexrelid)
  AND (i.indexrelid::regclass)::text !~ ('^' || CASE WHEN i.indisunique THEN 'uq' ELSE 'ix' END || '_' || t.relname || '_');

-- Names stay below the 63 characters at which PostgreSQL silently truncates them.
SELECT 'name of 63 characters or more (possibly truncated): ' || relname
FROM pg_class
WHERE relnamespace = 'public'::regnamespace AND length(relname) >= 63
UNION ALL
SELECT 'name of 63 characters or more (possibly truncated): ' || conname
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace AND length(conname) >= 63;

-- A table with its own identity (public_id) has created_at and updated_at.
SELECT 'table with public_id lacks ' || needed.column_name || ': ' || t.table_name
FROM information_schema.columns t
CROSS JOIN (VALUES ('created_at'), ('updated_at')) AS needed (column_name)
WHERE t.table_schema = 'public' AND t.column_name = 'public_id'
  AND NOT EXISTS (
      SELECT 1 FROM information_schema.columns c
      WHERE c.table_schema = 'public' AND c.table_name = t.table_name AND c.column_name = needed.column_name
  );

-- Every table is documented.
SELECT 'table without COMMENT ON TABLE: ' || c.relname
FROM pg_class c
WHERE c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
  AND c.relname NOT LIKE 'flyway%' AND c.relname <> 'idempotency_record'
  AND obj_description(c.oid, 'pg_class') IS NULL
  AND NOT EXISTS (SELECT 1 FROM pg_constraint pk WHERE pk.conrelid = c.oid AND pk.contype = 'p' AND array_length(pk.conkey, 1) > 1);
