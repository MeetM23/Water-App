-- 0014_dealer_rpcs.sql
-- Owner-only dealer administration.
--
-- Each routine re-asserts is_owner() in its own body. SECURITY DEFINER means
-- the function bypasses RLS, so that assertion is the only thing standing
-- between a dealer and the profiles table: it is never optional, and it raises
-- rather than returning quietly so the client cannot mistake refusal for
-- success.

create or replace function public.approve_dealer(
  p_user uuid,
  p_role public.user_role
)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $fn$
declare
  v_profile public.profiles;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may approve dealers'
      using errcode = '42501';
  end if;

  if p_role not in ('wholesaler', 'retailer') then
    raise exception 'A dealer may only be approved as wholesaler or retailer'
      using errcode = '22023';
  end if;

  update public.profiles
     set role             = p_role,
         status           = 'approved',
         approved_at      = now(),
         approved_by      = auth.uid(),
         rejection_reason = null
   where id = p_user
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user
      using errcode = 'P0002';
  end if;

  perform public.write_audit_log(
    'dealer.approved', 'profile', p_user,
    jsonb_build_object('role', p_role)
  );

  return v_profile;
end;
$fn$;

create or replace function public.reject_dealer(
  p_user   uuid,
  p_reason text
)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $fn$
declare
  v_profile public.profiles;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may reject dealers'
      using errcode = '42501';
  end if;

  if coalesce(trim(p_reason), '') = '' then
    raise exception 'A rejection reason is required'
      using errcode = '22023';
  end if;

  update public.profiles
     set status           = 'rejected',
         rejection_reason = trim(p_reason),
         approved_at      = null,
         approved_by      = auth.uid()
   where id = p_user
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user
      using errcode = 'P0002';
  end if;

  perform public.write_audit_log(
    'dealer.rejected', 'profile', p_user,
    jsonb_build_object('reason', trim(p_reason))
  );

  return v_profile;
end;
$fn$;

create or replace function public.suspend_dealer(p_user uuid)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $fn$
declare
  v_profile public.profiles;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may suspend dealers'
      using errcode = '42501';
  end if;

  if p_user = auth.uid() then
    raise exception 'The owner cannot suspend their own account'
      using errcode = '22023';
  end if;

  update public.profiles
     set status = 'suspended'
   where id = p_user
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user
      using errcode = 'P0002';
  end if;

  perform public.write_audit_log('dealer.suspended', 'profile', p_user);

  return v_profile;
end;
$fn$;

create or replace function public.reactivate_dealer(p_user uuid)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $fn$
declare
  v_profile public.profiles;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may reactivate dealers'
      using errcode = '42501';
  end if;

  update public.profiles
     set status           = 'approved',
         approved_at      = now(),
         approved_by      = auth.uid(),
         rejection_reason = null
   where id = p_user
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user
      using errcode = 'P0002';
  end if;

  perform public.write_audit_log('dealer.reactivated', 'profile', p_user);

  return v_profile;
end;
$fn$;

revoke execute on function public.approve_dealer(uuid, public.user_role) from public;
revoke execute on function public.reject_dealer(uuid, text)              from public;
revoke execute on function public.suspend_dealer(uuid)                   from public;
revoke execute on function public.reactivate_dealer(uuid)                from public;

grant execute on function public.approve_dealer(uuid, public.user_role) to authenticated;
grant execute on function public.reject_dealer(uuid, text)              to authenticated;
grant execute on function public.suspend_dealer(uuid)                   to authenticated;
grant execute on function public.reactivate_dealer(uuid)                to authenticated;
