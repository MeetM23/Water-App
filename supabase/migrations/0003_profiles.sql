-- 0003_profiles.sql
-- One row per authenticated user. `role` and `status` here are the single
-- source of truth for every authorisation decision in the database; nothing
-- in the client is trusted to report either value.

create table if not exists public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  role             public.user_role      not null default 'retailer',
  status           public.account_status not null default 'pending',
  full_name        text        not null,
  firm_name        text        not null,
  phone            text        not null,
  city             text        not null,
  state            text        not null default 'Gujarat',
  gst_number       text,
  address          text,
  created_at       timestamptz not null default now(),
  approved_at      timestamptz,
  approved_by      uuid references auth.users (id),
  rejection_reason text
);

comment on table public.profiles is
  'Per-user role and approval state. Authorisation source of truth.';

create index if not exists profiles_status_idx on public.profiles (status);
create index if not exists profiles_role_idx   on public.profiles (role);

-- Mirrors a new auth.users row into public.profiles.
--
-- The role is taken from the sign-up metadata but is clamped to the two
-- self-selectable roles: an attacker who posts role="owner" during sign-up
-- lands on 'retailer'. The status is hardcoded to 'pending' and is never read
-- from metadata, so no account can self-approve.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_metadata jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_role     public.user_role;
begin
  v_role := case lower(coalesce(v_metadata ->> 'role', ''))
              when 'wholesaler' then 'wholesaler'::public.user_role
              else 'retailer'::public.user_role
            end;

  insert into public.profiles (
    id, role, status, full_name, firm_name, phone, city, state,
    gst_number, address
  )
  values (
    new.id,
    v_role,
    'pending',
    coalesce(v_metadata ->> 'full_name', ''),
    coalesce(v_metadata ->> 'firm_name', ''),
    coalesce(v_metadata ->> 'phone', ''),
    coalesce(v_metadata ->> 'city', ''),
    coalesce(nullif(v_metadata ->> 'state', ''), 'Gujarat'),
    nullif(v_metadata ->> 'gst_number', ''),
    nullif(v_metadata ->> 'address', '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

grant select, update on public.profiles to authenticated;
revoke all on public.profiles from anon;
