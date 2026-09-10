-- 0017_owner_analytics.sql
-- Read-only aggregates behind the owner dashboard and the dealer detail
-- screen.
--
-- These are SECURITY DEFINER because they aggregate across every dealer's
-- scan activity, which no RLS policy exposes row by row. Each one therefore
-- re-asserts is_owner() in its own body, exactly as the dealer RPCs do.
--
-- They exist as routines rather than as client-side queries because the
-- alternative is pulling the whole scan_events table to the phone and counting
-- it there, which is slow on a rural connection and gets slower every week.

-- Products scanned most often in the last p_days days.
create or replace function public.top_scanned_products(
  p_days  int default 30,
  p_limit int default 5
)
returns table (
  product_id   uuid,
  name         text,
  product_code text,
  scan_count   bigint
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may read scan analytics'
      using errcode = '42501';
  end if;

  return query
    select p.id, p.name, p.product_code, count(s.id)
      from public.scan_events s
      join public.products p on p.id = s.product_id
     where s.scanned_at >= now() - make_interval(days => greatest(p_days, 1))
     group by p.id, p.name, p.product_code
     order by count(s.id) desc, p.name asc
     limit greatest(p_limit, 1);
end;
$fn$;

-- The dealer-facing half of the audit log, joined to the firm it concerns.
--
-- entity_id on a dealer action is the dealer's profile id, so the join gives
-- the owner "Aqua Grand approved" rather than a bare uuid.
create or replace function public.recent_dealer_activity(p_limit int default 8)
returns table (
  id         uuid,
  action     text,
  firm_name  text,
  full_name  text,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may read the activity feed'
      using errcode = '42501';
  end if;

  return query
    select a.id,
           a.action,
           coalesce(p.firm_name, ''),
           coalesce(p.full_name, ''),
           a.created_at
      from public.audit_log a
      left join public.profiles p on p.id = a.entity_id
     where a.entity = 'profile'
     order by a.created_at desc
     limit greatest(p_limit, 1);
end;
$fn$;

-- Headline dealer counts, in one round trip instead of four.
create or replace function public.dealer_counts()
returns table (
  pending     bigint,
  wholesalers bigint,
  retailers   bigint,
  suspended   bigint
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may read dealer counts'
      using errcode = '42501';
  end if;

  return query
    select count(*) filter (where status = 'pending'),
           count(*) filter (where status = 'approved' and role = 'wholesaler'),
           count(*) filter (where status = 'approved' and role = 'retailer'),
           count(*) filter (where status = 'suspended')
      from public.profiles
     where role <> 'owner';
end;
$fn$;

-- Activity totals for one dealer, shown on their detail screen.
create or replace function public.dealer_activity(p_user uuid)
returns table (
  total_scans bigint,
  last_active timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may read dealer activity'
      using errcode = '42501';
  end if;

  return query
    select count(*), max(scanned_at)
      from public.scan_events
     where scanned_by = p_user;
end;
$fn$;

-- The email address behind a profile.
--
-- profiles deliberately does not duplicate auth.users.email, so the owner
-- needs a supervised way to read it: to send a password reset, and to see who
-- an account actually belongs to. Owner-only, one address at a time, never a
-- bulk dump.
create or replace function public.dealer_email(p_user uuid)
returns text
language plpgsql
stable
security definer
set search_path = public, pg_temp, auth
as $fn$
declare
  v_email text;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may read a dealer email address'
      using errcode = '42501';
  end if;

  select u.email into v_email from auth.users u where u.id = p_user;

  if v_email is null then
    raise exception 'No account found for user %', p_user
      using errcode = 'P0002';
  end if;

  return v_email;
end;
$fn$;

revoke execute on function public.top_scanned_products(int, int)   from public;
revoke execute on function public.recent_dealer_activity(int)      from public;
revoke execute on function public.dealer_counts()                  from public;
revoke execute on function public.dealer_activity(uuid)            from public;
revoke execute on function public.dealer_email(uuid)               from public;

grant execute on function public.top_scanned_products(int, int) to authenticated;
grant execute on function public.recent_dealer_activity(int)    to authenticated;
grant execute on function public.dealer_counts()                to authenticated;
grant execute on function public.dealer_activity(uuid)          to authenticated;
grant execute on function public.dealer_email(uuid)             to authenticated;
