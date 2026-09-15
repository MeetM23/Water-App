-- =============================================================================
-- 0028_fix_auth_profiles_trigger.sql
-- Production-Safe Auth Data Consistency Fix
--
-- 1. Replace handle_new_user() trigger function:
--    - Exact business rules: Retailer -> approved, Wholesaler -> pending, Owner -> approved
--    - Reliable metadata extraction with sensible fallbacks
--    - SECURITY DEFINER to bypass RLS
--    - Error handling to guarantee a profile row is ALWAYS created
-- 2. Backfill existing orphaned auth.users records into public.profiles
--    - Strict left-join (only unprofiled users)
--    - No duplicates, no overwriting of existing profiles
-- 3. Lock down permissions
-- =============================================================================

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  v_metadata jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_role     public.user_role;
  v_status   public.account_status;
  v_name     text;
  v_firm     text;
  v_phone    text;
  v_city     text;
  v_state    text;
begin
  -- Resolve role strictly from registration metadata
  v_role := case lower(coalesce(v_metadata ->> 'role', ''))
              when 'owner' then 'owner'::public.user_role
              when 'wholesaler' then 'wholesaler'::public.user_role
              else 'retailer'::public.user_role
            end;

  -- Resolve account status according to business rules:
  -- Wholesaler: pending (requires Admin approval)
  -- Retailer: approved (login immediately, never waits for Admin approval)
  -- Owner: approved (login immediately)
  v_status := case v_role
                when 'wholesaler'::public.user_role then 'pending'::public.account_status
                else 'approved'::public.account_status
              end;

  -- Sensible defaults
  v_name  := coalesce(nullif(trim(v_metadata ->> 'full_name'), ''), nullif(split_part(new.email, '@', 1), ''), 'User');
  v_firm  := coalesce(nullif(trim(v_metadata ->> 'firm_name'), ''), 'Business');
  v_phone := coalesce(trim(v_metadata ->> 'phone'), '');
  v_city  := coalesce(trim(v_metadata ->> 'city'), '');
  v_state := coalesce(nullif(trim(v_metadata ->> 'state'), ''), 'Gujarat');

  insert into public.profiles (
    id, role, status, full_name, firm_name, phone, city, state, gst_number, address, created_at
  )
  values (
    new.id,
    v_role,
    v_status,
    v_name,
    v_firm,
    v_phone,
    v_city,
    v_state,
    nullif(trim(v_metadata ->> 'gst_number'), ''),
    nullif(trim(v_metadata ->> 'address'), ''),
    coalesce(new.created_at, now())
  )
  on conflict (id) do update set
    role = case
             when profiles.role = 'owner' then profiles.role
             else excluded.role
           end,
    full_name = case
                  when profiles.full_name is null or profiles.full_name = '' or profiles.full_name = 'User'
                  then excluded.full_name
                  else profiles.full_name
                end,
    firm_name = case
                  when profiles.firm_name is null or profiles.firm_name = '' or profiles.firm_name = 'Business'
                  then excluded.firm_name
                  else profiles.firm_name
                end,
    phone = case
              when profiles.phone is null or profiles.phone = ''
              then excluded.phone
              else profiles.phone
            end,
    city = case
             when profiles.city is null or profiles.city = ''
             then excluded.city
             else profiles.city
           end,
    state = case
              when profiles.state is null or profiles.state = ''
              then excluded.state
              else profiles.state
            end,
    gst_number = coalesce(profiles.gst_number, excluded.gst_number),
    address = coalesce(profiles.address, excluded.address);

  return new;
exception when others then
  -- Safe fallback: guarantee profile existence so user is never orphaned
  insert into public.profiles (
    id, role, status, full_name, firm_name, phone, city, state, created_at
  )
  values (
    new.id,
    'retailer'::public.user_role,
    'approved'::public.account_status,
    coalesce(nullif(split_part(new.email, '@', 1), ''), 'User'),
    'Business',
    '',
    '',
    'Gujarat',
    coalesce(new.created_at, now())
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- Ensure trigger is active
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill existing orphaned auth.users records into public.profiles
insert into public.profiles (
  id, role, status, full_name, firm_name, phone, city, state, gst_number, address, created_at
)
select
  u.id,
  case lower(coalesce(u.raw_user_meta_data ->> 'role', ''))
    when 'owner' then 'owner'::public.user_role
    when 'wholesaler' then 'wholesaler'::public.user_role
    else 'retailer'::public.user_role
  end as role,
  case lower(coalesce(u.raw_user_meta_data ->> 'role', ''))
    when 'wholesaler' then 'pending'::public.account_status
    else 'approved'::public.account_status
  end as status,
  coalesce(nullif(trim(u.raw_user_meta_data ->> 'full_name'), ''), nullif(split_part(u.email, '@', 1), ''), 'User') as full_name,
  coalesce(nullif(trim(u.raw_user_meta_data ->> 'firm_name'), ''), 'Business') as firm_name,
  coalesce(trim(u.raw_user_meta_data ->> 'phone'), '') as phone,
  coalesce(trim(u.raw_user_meta_data ->> 'city'), '') as city,
  coalesce(nullif(trim(u.raw_user_meta_data ->> 'state'), ''), 'Gujarat') as state,
  nullif(trim(u.raw_user_meta_data ->> 'gst_number'), '') as gst_number,
  nullif(trim(u.raw_user_meta_data ->> 'address'), '') as address,
  coalesce(u.created_at, now()) as created_at
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null
on conflict (id) do nothing;

-- Ensure internal trigger execution is revoked from public/anon/authenticated
revoke all on function public.handle_new_user() from public, anon, authenticated;
