-- 0001_extensions.sql
-- Extensions required by later migrations and by seed.sql.
--
-- pgcrypto is already present on a stock Supabase project (installed into the
-- `extensions` schema); the guard below makes the migration set runnable on a
-- bare PostgreSQL instance as well, which is how the RLS test suite is run.

create extension if not exists pgcrypto;
