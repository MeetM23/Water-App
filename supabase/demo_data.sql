-- demo_data.sql
--
-- A catalogue and a dealer network big enough to photograph. NOT part of the
-- schema and NOT run by `supabase db reset`: apply it by hand against a
-- development database when the screenshots in docs/OWNER_GUIDE.md or the Play
-- Store listing need retaking.
--
--     psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/demo_data.sql
--
-- Never run this against production. Every account below uses the password
-- Passw0rd!123 and an @example.test address, both of which exist so the rows
-- are obviously fake to anybody who finds them later.
--
-- Safe to run more than once: products are keyed by name, accounts by email.

\set ON_ERROR_STOP on

do $demo$
declare
  v_owner uuid;
  v_row   record;
  v_user  uuid;
begin
  select id into v_owner from public.profiles
   where role = 'owner' order by created_at limit 1;

  if v_owner is null then
    raise exception 'No owner account exists. Run seed.sql first.';
  end if;

  -- -----------------------------------------------------------------------
  -- Catalogue
  -- -----------------------------------------------------------------------
  for v_row in
    select * from (values
      ('Aqua Pure 12 LPH Domestic RO',      'domestic',   'AP-12',   '12 LPH',    8400,  11900,   12, true),
      ('Aqua Pure 15 LPH Domestic RO',      'domestic',   'AP-15',   '15 LPH',    9600,  13500,   12, true),
      ('Aqua Grand UV plus UF Purifier',    'domestic',   'AG-UV',   '10 LPH',    6200,   8900,   12, true),
      ('Crystal Alkaline RO 14 LPH',        'domestic',   'CR-A14',  '14 LPH',   11800,  16400,   24, true),
      ('Crystal Copper RO 12 LPH',          'domestic',   'CR-C12',  '12 LPH',   10400,  14600,   24, false),
      ('Commercial RO Plant 100 LPH',       'commercial', 'CP-100',  '100 LPH',  42000,  58000,   12, true),
      ('Commercial RO Plant 250 LPH',       'commercial', 'CP-250',  '250 LPH',  68000,  96000,   12, true),
      ('Commercial RO Plant 500 LPH',       'commercial', 'CP-500',  '500 LPH', 112000, 156000,   12, true),
      ('Industrial RO Plant 1000 LPH',      'industrial', 'IP-1000', '1000 LPH',248000, 342000,   18, true),
      ('Industrial RO Plant 3000 LPH',      'industrial', 'IP-3000', '3000 LPH',612000, 798000,   18, true),
      ('Softener Plant 500 LPH',            'industrial', 'SP-500',  '500 LPH',  38000,  52000,   12, true),
      ('RO Membrane 80 GPD',                'spare_part', 'MB-80',   null,          820,   1250,   6, true),
      ('RO Membrane 100 GPD',               'spare_part', 'MB-100',  null,         1050,   1550,   6, true),
      ('Sediment Filter 10 inch',           'spare_part', 'SF-10',   null,           95,    180, null, true),
      ('Carbon Block Filter 10 inch',       'spare_part', 'CB-10',   null,          140,    260, null, true),
      ('Booster Pump 100 GPD',              'spare_part', 'BP-100',  null,          680,   1050,  12, true),
      ('SMPS Adaptor 24V 2.5A',             'spare_part', 'SM-24',   null,          310,    520,   6, false),
      ('Stainless Steel Storage Tank 20 L', 'accessory',  'ST-20',   '20 L',       1450,   2200,  12, true),
      ('Pre-filter Housing Set',            'accessory',  'PH-SET',  null,          540,    880, null, true),
      ('Installation Kit',                  'accessory',  'IK-STD',  null,          320,    560, null, true)
    ) as t(name, category, model, capacity, wholesale, retail, warranty, in_stock)
  loop
    if not exists (select 1 from public.products p where p.name = v_row.name) then
      insert into public.products (
        name, model_number, category, capacity,
        wholesale_price, retail_price, warranty_months, in_stock,
        description, specifications, created_by
      )
      values (
        v_row.name, v_row.model, v_row.category::public.product_category,
        v_row.capacity, v_row.wholesale, v_row.retail, v_row.warranty,
        v_row.in_stock,
        'Supplied, installed and serviced by Maruti Water Solution, Botad.',
        jsonb_build_object(
          'Stages', case when v_row.category = 'domestic' then '7' else '5' end,
          'Body', 'Food grade ABS',
          'Warranty', coalesce(v_row.warranty::text || ' months', 'Not applicable')
        ),
        v_owner
      );
    end if;
  end loop;

  -- -----------------------------------------------------------------------
  -- Dealer network: two approved wholesalers, two approved retailers, two
  -- waiting on the owner, one suspended. Enough to photograph every state the
  -- dealers screen can be in.
  -- -----------------------------------------------------------------------
  for v_row in
    select * from (values
      ('bhavna@example.test', 'Bhavnaben Patel',    'Bhavna Aqua Traders',   'Bhavnagar', 'wholesaler', 'approved',  '24AAACB1234C1ZK'),
      ('kiran@example.test',  'Kiranbhai Vaghela',  'Kiran Water Systems',   'Rajkot',    'wholesaler', 'approved',  '24AABCK5678D1ZM'),
      ('meena@example.test',  'Meenaben Trivedi',   'Shreeji Water Shop',    'Botad',     'retailer',   'approved',  null),
      ('rakesh@example.test', 'Rakeshbhai Solanki', 'Solanki Aqua Point',    'Amreli',    'retailer',   'approved',  '24AAECS9012E1ZP'),
      ('jayesh@example.test', 'Jayeshbhai Dave',    'Dave Water Solutions',  'Surat',     'retailer',   'pending',   null),
      ('nilesh@example.test', 'Nileshbhai Chauhan', 'Chauhan Enterprise',    'Gondal',    'wholesaler', 'pending',   '24AAFCC3456F1ZR'),
      ('dilip@example.test',  'Dilipbhai Makwana',  'Makwana Aqua Services', 'Palitana',  'retailer',   'suspended', null)
    ) as t(email, full_name, firm_name, city, role, status, gst)
  loop
    select id into v_user from auth.users where email = v_row.email;

    if v_user is null then
      v_user := gen_random_uuid();

      insert into auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        confirmation_token, recovery_token, email_change, email_change_token_new,
        created_at, updated_at
      )
      values (
        '00000000-0000-0000-0000-000000000000', v_user,
        'authenticated', 'authenticated', v_row.email,
        crypt('Passw0rd!123', gen_salt('bf')),
        now(), '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object(
          'full_name',  v_row.full_name,
          'firm_name',  v_row.firm_name,
          'phone',      '98' || lpad((random() * 99999999)::bigint::text, 8, '0'),
          'city',       v_row.city,
          'state',      'Gujarat',
          'gst_number', v_row.gst,
          'role',       v_row.role
        ),
        '', '', '', '',
        now() - (random() * interval '90 days'), now()
      );

      insert into auth.identities (
        provider_id, user_id, identity_data, provider,
        last_sign_in_at, created_at, updated_at
      )
      values (
        v_user::text, v_user,
        jsonb_build_object('sub', v_user::text, 'email', v_row.email),
        'email', now(), now(), now()
      )
      on conflict do nothing;
    end if;

    -- handle_new_user() created a pending row; settle it here.
    update public.profiles
       set role        = v_row.role::public.user_role,
           status      = v_row.status::public.account_status,
           gst_number  = v_row.gst,
           approved_at = case when v_row.status = 'approved' then now() end,
           approved_by = case when v_row.status = 'approved' then v_owner end
     where id = v_user;
  end loop;

  -- -----------------------------------------------------------------------
  -- Scan history, so the owner dashboard has something to rank.
  -- -----------------------------------------------------------------------
  if (select count(*) from public.scan_events) < 50 then
    insert into public.scan_events (
      product_id, scanned_by, scanned_role, source, scanned_at
    )
    select p.id, d.id, d.role,
           case when random() < 0.3 then 'manual' else 'camera' end,
           now() - (random() * interval '25 days')
      from public.products p
      cross join (
        select pr.id, pr.role from public.profiles pr
         where pr.status = 'approved' and pr.role <> 'owner'
      ) d
      cross join generate_series(1, 3)
     where random() < 0.7;
  end if;
end
$demo$;

select 'products'    as entity, count(*) from public.products
union all
select 'profiles',   count(*) from public.profiles
union all
select 'scan_events', count(*) from public.scan_events;
