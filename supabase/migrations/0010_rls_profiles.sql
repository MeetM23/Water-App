-- 0010_rls_profiles.sql
-- Row access for profiles, plus the column-level guard that stops a user from
-- promoting or approving themselves.

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own   on public.profiles;
drop policy if exists profiles_select_owner on public.profiles;
drop policy if exists profiles_update_own   on public.profiles;
drop policy if exists profiles_update_owner on public.profiles;

create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_select_owner on public.profiles
  for select to authenticated
  using (public.is_owner());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_update_owner on public.profiles
  for update to authenticated
  using (public.is_owner())
  with check (public.is_owner());

-- No INSERT or DELETE policy exists by design. Profiles are created solely by
-- the handle_new_user() trigger and removed by the cascade from auth.users.

-- Restricts *which columns* a user may change in their own row. An RLS
-- USING/WITH CHECK expression can only accept or reject the whole row, so the
-- privilege fields need a trigger.
--
-- auth.uid() is null on connections that carry no JWT (the Supabase SQL
-- editor, the service role, seeding). Those paths are already fully blocked by
-- the policies above for an anonymous caller, so skipping the check there is
-- safe, and it is what allows seed.sql to promote the first owner.
create or replace function public.guard_profile_privilege_columns()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null or public.is_owner() then
    return new;
  end if;

  if new.id             <> old.id
     or new.role        <> old.role
     or new.status      <> old.status
     or new.approved_at      is distinct from old.approved_at
     or new.approved_by      is distinct from old.approved_by
     or new.rejection_reason is distinct from old.rejection_reason
  then
    raise exception
      'A user cannot change their own role, status or approval fields'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

drop trigger if exists guard_profile_privilege_columns on public.profiles;
create trigger guard_profile_privilege_columns
  before update on public.profiles
  for each row execute function public.guard_profile_privilege_columns();
