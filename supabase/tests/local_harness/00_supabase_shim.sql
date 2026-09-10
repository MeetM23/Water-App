-- 00_supabase_shim.sql
--
-- TEST HARNESS ONLY. Never run this against a Supabase project.
--
-- A Supabase database ships with objects that a bare PostgreSQL instance does
-- not have: the auth and storage schemas, the auth.uid() claim reader, and the
-- anon / authenticated / service_role login roles. This file creates the
-- minimum subset of those objects so that the real, unmodified migration files
-- in supabase/migrations/ can be applied to a throwaway container and the RLS
-- suite can be executed against them.
--
-- Nothing here is part of the application schema.

create schema if not exists auth;
create schema if not exists storage;
create schema if not exists extensions;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end
$$;

grant usage on schema public  to anon, authenticated, service_role;
grant usage on schema auth    to anon, authenticated, service_role;
grant usage on schema storage to anon, authenticated, service_role;

-- Subset of the GoTrue user table. Only the columns the application schema
-- and seed.sql actually touch are modelled.
create table if not exists auth.users (
  instance_id        uuid,
  id                 uuid primary key,
  aud                text,
  role               text,
  email              text unique,
  encrypted_password text,
  email_confirmed_at timestamptz,
  raw_app_meta_data  jsonb default '{}'::jsonb,
  raw_user_meta_data jsonb default '{}'::jsonb,
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);

create table if not exists auth.identities (
  id              uuid default gen_random_uuid(),
  provider_id     text not null,
  user_id         uuid not null references auth.users (id) on delete cascade,
  identity_data   jsonb not null,
  provider        text not null,
  last_sign_in_at timestamptz,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now(),
  primary key (provider, provider_id)
);

-- Reads the caller identity out of the request claims exactly as Supabase
-- does, so `set_config('request.jwt.claims', ...)` in the test suite produces
-- the same auth.uid() behaviour as a real signed-in JWT.
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(
           nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub',
           ''
         )::uuid;
$$;

create or replace function auth.role()
returns text
language sql
stable
as $$
  select nullif(
           nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role',
           ''
         );
$$;

grant execute on function auth.uid()  to anon, authenticated, service_role;
grant execute on function auth.role() to anon, authenticated, service_role;

create table if not exists storage.buckets (
  id         text primary key,
  name       text not null,
  public     boolean not null default false,
  created_at timestamptz default now()
);

create table if not exists storage.objects (
  id         uuid primary key default gen_random_uuid(),
  bucket_id  text references storage.buckets (id),
  name       text,
  owner      uuid,
  metadata   jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

alter table storage.objects enable row level security;

grant select, insert, update, delete on storage.objects to authenticated;
grant select on storage.buckets to authenticated;
