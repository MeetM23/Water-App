-- 0016_business_settings.sql
-- The business details printed on labels and exports.
--
-- These live in a table rather than in AppConfig because the client changes a
-- phone number or moves premises far more often than we ship a build, and a
-- reprint of every label sheet must not wait on an app store review.
--
-- Exactly one row exists. The singleton is enforced by a fixed primary key
-- rather than by the client remembering to update instead of insert.

create table if not exists public.business_settings (
  id           boolean primary key default true,
  business_name text        not null default 'Maruti Water Solution',
  phone         text        not null default '',
  address       text        not null default '',
  updated_at    timestamptz not null default now(),
  updated_by    uuid references auth.users (id),

  -- The whole point of the singleton: the primary key can only ever be true.
  constraint business_settings_singleton check (id)
);

comment on table public.business_settings is
  'Single row of business details printed on labels and exports.';

insert into public.business_settings (id) values (true)
  on conflict (id) do nothing;

alter table public.business_settings enable row level security;

drop policy if exists business_settings_select on public.business_settings;
drop policy if exists business_settings_update on public.business_settings;

-- Every approved account may read them: the details end up on printed labels
-- and on the catalogue export, neither of which is owner-only information.
create policy business_settings_select on public.business_settings
  for select to authenticated
  using (public.is_approved());

create policy business_settings_update on public.business_settings
  for update to authenticated
  using (public.is_owner())
  with check (public.is_owner());

-- No INSERT or DELETE policy. The single row is seeded above and is never
-- created or removed by a client.

create or replace function public.touch_business_settings()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  new.id         := true;
  return new;
end;
$$;

drop trigger if exists touch_business_settings on public.business_settings;
create trigger touch_business_settings
  before update on public.business_settings
  for each row execute function public.touch_business_settings();

grant select, update on public.business_settings to authenticated;
revoke all on public.business_settings from anon;
