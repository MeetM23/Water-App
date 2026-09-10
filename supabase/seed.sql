-- seed.sql
-- One owner account and three sample products, for a freshly migrated
-- database. Safe to run more than once.
--
-- The owner credentials below are a DEVELOPMENT convenience. Before handing
-- the project to the client, either change the password here or follow the
-- production path documented in README.md: let the owner sign up through the
-- app like anybody else, then promote that account with promote_owner().

do $seed$
declare
  v_owner_id  uuid := '00000000-0000-4000-8000-000000000001';
  v_email     text := 'owner@marutiwater.local';
  v_password  text := 'MarutiOwner#2026';
  v_now       timestamptz := now();
begin
  if not exists (select 1 from auth.users where id = v_owner_id) then
    -- The four token columns are written as empty strings, not left to
    -- default. GoTrue scans them into non-nullable Go strings, so a NULL in any
    -- one of them makes every sign-in attempt for this account fail with
    -- "Database error querying schema" -- a message that says nothing about
    -- the account and sends you looking at the password. A row created through
    -- the signup endpoint gets '' in all four, which is what this matches.
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token,
      email_change, email_change_token_new,
      created_at, updated_at
    )
    values (
      '00000000-0000-0000-0000-000000000000',
      v_owner_id,
      'authenticated',
      'authenticated',
      v_email,
      crypt(v_password, gen_salt('bf')),
      v_now,
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object(
        'full_name', 'Maruti Water Solution',
        'firm_name', 'Maruti Water Solution',
        'phone',     '0000000000',
        'city',      'Botad',
        'state',     'Gujarat'
      ),
      '', '', '', '',
      v_now,
      v_now
    );

    insert into auth.identities (
      provider_id, user_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    )
    values (
      v_owner_id::text,
      v_owner_id,
      jsonb_build_object('sub', v_owner_id::text, 'email', v_email),
      'email',
      v_now, v_now, v_now
    )
    on conflict do nothing;
  end if;

  -- handle_new_user() created this row as a pending retailer; promote it.
  update public.profiles
     set role        = 'owner',
         status      = 'approved',
         full_name   = 'Maruti Water Solution',
         firm_name   = 'Maruti Water Solution',
         phone       = '0000000000',
         city        = 'Botad',
         state       = 'Gujarat',
         approved_at = v_now,
         approved_by = v_owner_id
   where id = v_owner_id;

  if not exists (select 1 from public.products) then
    insert into public.products (
      name, model_number, category, description, capacity,
      specifications, mrp, wholesale_price, retail_price,
      warranty_months, created_by
    )
    values
      (
        'Aqua Grand Domestic RO Purifier',
        'MW-DOM-12',
        'domestic',
        'Twelve litre under-sink RO purifier with UV and TDS control, for '
          || 'household drinking water.',
        '12 L',
        '{"stages":7,"membrane":"75 GPD","uv":true,"tds_controller":true}'::jsonb,
        18500.00, 11200.00, 15900.00, 12, v_owner_id
      ),
      (
        'Commercial RO Plant 250 LPH',
        'MW-COM-250',
        'commercial',
        'Skid mounted commercial reverse osmosis plant for restaurants, '
          || 'schools and small hotels.',
        '250 LPH',
        '{"pump":"CNP 1 HP","membrane":"4040 x 2","frame":"SS 304"}'::jsonb,
        142000.00, 96000.00, 128500.00, 12, v_owner_id
      ),
      (
        'Industrial RO Plant 3000 LPH',
        'MW-IND-3000',
        'industrial',
        'High capacity industrial reverse osmosis plant with automatic '
          || 'backwash and dosing system.',
        '3000 LPH',
        '{"pump":"Grundfos 5 HP","membrane":"8040 x 4","frame":"MS epoxy"}'::jsonb,
        865000.00, 612000.00, 798000.00, 18, v_owner_id
      );
  end if;
end
$seed$;

-- Promotes an existing, app-created account to owner. This is the supported
-- production path for creating the first owner; run it from the Supabase SQL
-- editor after that person has signed up through the app.
--
-- The two safeguards below are not decoration. Without them this routine was
-- callable over PostgREST by an anonymous caller holding nothing but the anon
-- key that ships inside the APK, and it handed out the owner role -- both price
-- columns, the dealer network, every dealer's email address. See
-- 0019_routine_grants.sql for how the revoke that was supposed to prevent that
-- failed to take effect.
create or replace function public.promote_owner(p_email text)
returns void
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $fn$
declare
  v_user_id uuid;
begin
  -- Deliberately NOT is_owner(): this routine exists to create the first owner,
  -- at a moment when there is no owner to authorise it. What separates that
  -- from an attack is whether an owner already exists.
  if exists (
       select 1 from public.profiles
        where role = 'owner' and status = 'approved'
     ) and not public.is_owner() then
    raise exception
      'An owner already exists; only the owner may promote another account'
      using errcode = '42501';
  end if;

  select id into v_user_id from auth.users where lower(email) = lower(p_email);

  if v_user_id is null then
    raise exception 'No account exists for %', p_email using errcode = 'P0002';
  end if;

  update public.profiles
     set role        = 'owner',
         status      = 'approved',
         approved_at = now()
   where id = v_user_id;
end;
$fn$;

-- `from public` alone is not enough. Supabase's default privileges grant
-- execute on every new function in this schema to anon and authenticated
-- explicitly, and revoking PUBLIC does not touch an explicit grant. Both roles
-- have to be named.
revoke execute on function public.promote_owner(text)
  from public, anon, authenticated;
