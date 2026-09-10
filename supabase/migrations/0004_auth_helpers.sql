-- 0004_auth_helpers.sql
-- Authorisation primitives used by every policy, view and RPC.
--
-- All four are SECURITY DEFINER so that they can read public.profiles without
-- being subject to the very policies that call them, which would otherwise
-- recurse. search_path is pinned so a caller cannot shadow `profiles` with a
-- table of their own in a schema they control.

create or replace function public.auth_role()
returns public.user_role
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p.role from public.profiles p where p.id = auth.uid();
$$;

create or replace function public.auth_status()
returns public.account_status
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p.status from public.profiles p where p.id = auth.uid();
$$;

create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'owner'
      and p.status = 'approved'
  );
$$;

create or replace function public.is_approved()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.status = 'approved'
  );
$$;

comment on function public.is_owner() is
  'True only for an approved owner. A suspended owner loses all owner rights.';

revoke execute on function public.auth_role()   from public;
revoke execute on function public.auth_status() from public;
revoke execute on function public.is_owner()    from public;
revoke execute on function public.is_approved() from public;

grant execute on function public.auth_role()   to authenticated;
grant execute on function public.auth_status() to authenticated;
grant execute on function public.is_owner()    to authenticated;
grant execute on function public.is_approved() to authenticated;
