-- 0018_dealer_role_change.sql
-- Moving an already-approved dealer between wholesaler and retailer.
--
-- approve_dealer() would also change the role, but it rewrites approved_at and
-- approved_by as a side effect, which would quietly destroy the record of when
-- the relationship actually started. Repricing a dealer six months in is a
-- different event from approving them, so it gets its own routine and its own
-- audit action.

create or replace function public.set_dealer_role(
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
  v_previous public.user_role;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may change a dealer role'
      using errcode = '42501';
  end if;

  if p_role not in ('wholesaler', 'retailer') then
    raise exception 'A dealer may only be a wholesaler or a retailer'
      using errcode = '22023';
  end if;

  select role into v_previous from public.profiles where id = p_user;

  if v_previous is null then
    raise exception 'No profile found for user %', p_user
      using errcode = 'P0002';
  end if;

  if v_previous = 'owner' then
    raise exception 'The owner account cannot be given a dealer role'
      using errcode = '22023';
  end if;

  update public.profiles
     set role = p_role
   where id = p_user
  returning * into v_profile;

  perform public.write_audit_log(
    'dealer.role_changed', 'profile', p_user,
    jsonb_build_object('from', v_previous, 'to', p_role)
  );

  return v_profile;
end;
$fn$;

revoke execute on function public.set_dealer_role(uuid, public.user_role)
  from public;
grant execute on function public.set_dealer_role(uuid, public.user_role)
  to authenticated;
