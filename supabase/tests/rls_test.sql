-- rls_test.sql
--
-- Adversarial verification of the price-isolation and approval rules.
--
-- Every check runs as a real signed-in dealer: the session role is switched to
-- `authenticated` and request.jwt.claims is populated with that user id, which
-- is exactly how Supabase presents an authenticated PostgREST request to the
-- database. No check is performed as a superuser.
--
-- The whole file runs inside a transaction that is rolled back at the end, so
-- it leaves no fixtures behind and is safe to run against a seeded database.
--
-- Checks a..t are the original Phase 1A suite and are unchanged. Checks u..z
-- were added in Phase 3, and two of them change the character of the file:
--
--   * The suite now builds a realistic volume of data before it runs -- 500
--     products, 60 dealers and several thousand scan events -- and the price
--     checks then assert over EVERY row a dealer receives rather than over one
--     hand-placed fixture. A spot check on a single row cannot tell the
--     difference between "the view resolves the right price" and "the view
--     happened to resolve the right price for that row".
--
--   * Check v3 does not test a routine. It enumerates every routine, and fails
--     if any of them is reachable by a dealer, bypasses RLS, and does not
--     assert is_owner() in its own body. Written that way so it also fails for
--     an RPC that does not exist yet.
--
-- Usage:
--   psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/rls_test.sql
--
-- Exit status is non-zero if any check fails.

\set ON_ERROR_STOP on

begin;

create temporary table rls_result (
  check_id    text,
  description text,
  expected    text,
  actual      text,
  passed      boolean
) on commit drop;

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------

do $fixtures$
declare
  v_owner      uuid := '11111111-1111-4111-8111-111111111111';
  v_wholesaler uuid := '22222222-2222-4222-8222-222222222222';
  v_retailer   uuid := '33333333-3333-4333-8333-333333333333';
  v_pending    uuid := '44444444-4444-4444-8444-444444444444';
begin
  insert into auth.users (id, aud, role, email, raw_user_meta_data)
  values
    (v_owner,      'authenticated', 'authenticated', 'test-owner@example.test',
     '{"full_name":"Test Owner","firm_name":"Maruti Water Solution","phone":"9000000001","city":"Botad"}'::jsonb),
    (v_wholesaler, 'authenticated', 'authenticated', 'test-wholesaler@example.test',
     '{"full_name":"Test Wholesaler","firm_name":"Bhavnagar Aqua Traders","phone":"9000000002","city":"Bhavnagar","role":"wholesaler"}'::jsonb),
    (v_retailer,   'authenticated', 'authenticated', 'test-retailer@example.test',
     '{"full_name":"Test Retailer","firm_name":"Rajkot Water Shop","phone":"9000000003","city":"Rajkot","role":"retailer"}'::jsonb),
    (v_pending,    'authenticated', 'authenticated', 'test-pending@example.test',
     '{"full_name":"Test Pending","firm_name":"Surat Pure Water","phone":"9000000004","city":"Surat","role":"retailer"}'::jsonb);

  -- handle_new_user() has created all four profiles as pending. Promote the
  -- three that the checks need approved; the fourth stays pending on purpose.
  update public.profiles set role = 'owner',      status = 'approved' where id = v_owner;
  update public.profiles set role = 'wholesaler', status = 'approved' where id = v_wholesaler;
  update public.profiles set role = 'retailer',   status = 'approved' where id = v_retailer;

  insert into public.products (
    name, category, capacity, wholesale_price, retail_price, created_by
  )
  values (
    'RLS Fixture Purifier', 'domestic', '12 L', 5000.00, 7500.00, v_owner
  );
end
$fixtures$;

-- ---------------------------------------------------------------------------
-- Volume fixtures
-- ---------------------------------------------------------------------------
--
-- Enough rows that a policy which works on one record but not on a set has
-- somewhere to fail. The two price bands never overlap: wholesale figures live
-- in 1000..1499 and retail figures in 90000..90499. One numeric range check
-- over every row a dealer receives therefore proves that not a single row came
-- off the other list, which is a far stronger statement than "the one fixture
-- product showed the right number".

do $volume$
declare
  v_owner       uuid := '11111111-1111-4111-8111-111111111111';
  v_wholesaler  uuid := '22222222-2222-4222-8222-222222222222';
  v_retailer    uuid := '33333333-3333-4333-8333-333333333333';
  v_products    constant int := 500;
  v_dealers     constant int := 60;
  v_scans       constant int := 4000;
begin
  insert into public.products (
    name, category, capacity, wholesale_price, retail_price, in_stock, created_by
  )
  select
    'Volume Fixture ' || i,
    (array[
      'domestic', 'commercial', 'industrial', 'spare_part', 'accessory'
    ])[1 + (i % 5)]::public.product_category,
    ((i % 40) + 5) || ' L',
    1000  + (i % 500),
    90000 + (i % 500),
    (i % 7) <> 0,
    v_owner
  from generate_series(1, v_products) i;

  -- A dealer network, half wholesale and half retail, with a handful of
  -- pending and suspended accounts mixed in. handle_new_user() creates each
  -- profile as pending; the update below settles them.
  insert into auth.users (id, aud, role, email, raw_user_meta_data)
  select
    ('55555555-5555-4555-8555-' || lpad(i::text, 12, '0'))::uuid,
    'authenticated', 'authenticated',
    'volume-dealer-' || i || '@example.test',
    jsonb_build_object(
      'full_name', 'Volume Dealer ' || i,
      'firm_name', 'Volume Traders ' || i,
      'phone',     '90000' || lpad(i::text, 5, '0'),
      'city',      'Botad',
      'role',      case when i % 2 = 0 then 'wholesaler' else 'retailer' end
    )
  from generate_series(1, v_dealers) i;

  update public.profiles p
     set role   = case when (right(p.id::text, 3))::int % 2 = 0
                       then 'wholesaler'::public.user_role
                       else 'retailer'::public.user_role end,
         status = case when (right(p.id::text, 3))::int % 10 = 3
                       then 'pending'::public.account_status
                       when (right(p.id::text, 3))::int % 10 = 7
                       then 'suspended'::public.account_status
                       else 'approved'::public.account_status end
   where p.id::text like '55555555-5555-4555-8555-%';

  -- Scan telemetry, attributed across the whole network. This is the table a
  -- dealer must never read back, and it is worth reading back at a size where
  -- a missing policy would return something interesting.
  insert into public.scan_events (product_id, scanned_by, scanned_role, source)
  select
    p.id,
    case when i % 2 = 0 then v_wholesaler else v_retailer end,
    case when i % 2 = 0 then 'wholesaler'::public.user_role
                        else 'retailer'::public.user_role end,
    case when i % 3 = 0 then 'manual' else 'camera' end
  from generate_series(1, v_scans) i
  join lateral (
    select id from public.products
     where name like 'Volume Fixture %'
     offset (i % v_products) limit 1
  ) p on true;

  analyze public.products;
  analyze public.profiles;
  analyze public.scan_events;
end
$volume$;

-- ---------------------------------------------------------------------------
-- Checks
-- ---------------------------------------------------------------------------

do $checks$
declare
  v_owner      uuid := '11111111-1111-4111-8111-111111111111';
  v_wholesaler uuid := '22222222-2222-4222-8222-222222222222';
  v_retailer   uuid := '33333333-3333-4333-8333-333333333333';
  v_pending    uuid := '44444444-4444-4444-8444-444444444444';
  v_product    uuid;
  v_count      bigint;
  v_price      numeric;
  v_text       text;
  v_state      text;
begin
  select id into v_product from public.products
   where name = 'RLS Fixture Purifier';

  -- (a) A wholesaler reading the base table sees nothing at all.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.products;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'a', 'wholesaler: SELECT on products', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (b) The same wholesaler reads the catalogue and gets the wholesale price.
  perform set_config('role', 'authenticated', true);
  select price into v_price from public.catalog_view where id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'b', 'wholesaler: catalog_view.price', '5000.00', coalesce(v_price::text, 'null'),
    v_price = 5000.00);

  -- (c) A retailer reads the same row and gets the retail price.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select price into v_price from public.catalog_view where id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'c', 'retailer: catalog_view.price', '7500.00', coalesce(v_price::text, 'null'),
    v_price = 7500.00);

  -- (d1) Neither price column exists on the view, so neither can be projected.
  select string_agg(column_name, ', ' order by column_name) into v_text
    from information_schema.columns
   where table_schema = 'public' and table_name = 'catalog_view'
     and column_name in ('wholesale_price', 'retail_price');
  insert into rls_result values (
    'd1', 'catalog_view exposes no raw price column', 'none',
    coalesce(v_text, 'none'), v_text is null);

  -- (d2) A wholesaler asking for retail_price by name is rejected by the parser.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    execute 'select retail_price from public.catalog_view limit 1' into v_price;
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'd2', 'wholesaler: SELECT retail_price FROM catalog_view',
    '42703 undefined_column', v_state, v_state = '42703');

  -- (d3) And the mirror image for a retailer reaching for wholesale_price.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    execute 'select wholesale_price from public.catalog_view limit 1' into v_price;
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'd3', 'retailer: SELECT wholesale_price FROM catalog_view',
    '42703 undefined_column', v_state, v_state = '42703');

  -- (d4) The whole view row for a wholesaler must not contain 7500 anywhere.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select to_jsonb(c)::text into v_text from public.catalog_view c where c.id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'd4', 'wholesaler: retail figure absent from entire view row',
    'no 7500 in row', case when v_text like '%7500%' then 'LEAKED' else 'absent' end,
    v_text not like '%7500%');

  -- (e) A pending account sees an empty catalogue.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_pending, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.catalog_view;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'e', 'pending user: SELECT on catalog_view', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (f) A dealer calling the approval RPC is refused, loudly.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.approve_dealer(v_pending, 'retailer'::public.user_role);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'f', 'wholesaler: approve_dealer()', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (g) A dealer cannot approve themselves by editing their own profile row.
  perform set_config('role', 'authenticated', true);
  begin
    update public.profiles set status = 'approved', role = 'owner'
     where id = v_wholesaler;
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'g', 'wholesaler: self-promotion via UPDATE profiles',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (h) A dealer sees only their own profile, never the dealer network.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.profiles;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'h', 'wholesaler: SELECT on profiles', '1 row (own)', v_count || ' rows',
    v_count = 1);

  -- (i) A pending account cannot read the base table either.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_pending, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.products;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'i', 'pending user: SELECT on products', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (j) The owner, and only the owner, reads both prices from the base table.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select wholesale_price || ' / ' || retail_price into v_text
    from public.products where id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'j', 'owner: SELECT both prices on products', '5000.00 / 7500.00',
    coalesce(v_text, 'null'), v_text = '5000.00 / 7500.00');

  -- (k) The audit trail is closed to dealers even for insertion.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    execute $q$insert into public.audit_log (action, entity) values ('forged', 'profile')$q$;
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'k', 'retailer: INSERT into audit_log', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (l) A dealer may read the business details: they are printed on labels
  --     and on the catalogue, so they are not owner-only information.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.business_settings;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'l', 'retailer: SELECT on business_settings', '1 row', v_count || ' rows',
    v_count = 1);

  -- (m) ...but may not rewrite the phone number printed on every label.
  perform set_config('role', 'authenticated', true);
  begin
    execute $q$update public.business_settings set phone = '0000000000'$q$;
    -- An UPDATE filtered out by RLS affects zero rows rather than raising, so
    -- the check has to look at the row count, not at an error code.
    get diagnostics v_count = row_count;
    v_state := v_count || ' rows';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'm', 'retailer: UPDATE business_settings', '0 rows', v_state,
    v_state = '0 rows');

  -- (n) A pending account cannot even read them, because is_approved() is
  --     false and the select policy tests exactly that.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_pending, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.business_settings;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'n', 'pending user: SELECT on business_settings', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (o) The owner-only analytics routines refuse a dealer outright. These are
  --     SECURITY DEFINER and therefore bypass RLS entirely: the is_owner()
  --     assertion inside each body is the only thing protecting them, so it
  --     is worth proving rather than assuming.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.dealer_counts();
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'o', 'wholesaler: dealer_counts()', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (p) The same for the scan analytics, which aggregate every dealer's
  --     activity and would otherwise leak one dealer's behaviour to another.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.top_scanned_products(30, 5);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'p', 'wholesaler: top_scanned_products()', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (q) And for the email lookup, which reaches into auth.users.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.dealer_email(v_retailer);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'q', 'wholesaler: dealer_email()', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (r) A dealer cannot promote themselves to wholesaler pricing through the
  --     role-change routine.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.set_dealer_role(v_wholesaler, 'wholesaler');
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'r', 'wholesaler: set_dealer_role() on self',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (s) The owner may use the same routines.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.dealer_counts();
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    's', 'owner: dealer_counts()', 'no error', v_state, v_state = 'no error');

  -- (t) Changing a role must not overwrite the approval date. That column is
  --     the record of when the relationship began, and approve_dealer() would
  --     destroy it, which is the entire reason set_dealer_role() exists.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.set_dealer_role(v_retailer, 'wholesaler');
    select role::text into v_text from public.profiles where id = v_retailer;
    v_state := v_text;
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    't', 'owner: set_dealer_role() changes the role', 'wholesaler',
    v_state, v_state = 'wholesaler');

  perform set_config('request.jwt.claims', '', true);
end
$checks$;

-- ---------------------------------------------------------------------------
-- Phase 3 checks: the retailer side, the routines, the telemetry, suspension
-- ---------------------------------------------------------------------------

do $phase3$
declare
  v_owner      uuid := '11111111-1111-4111-8111-111111111111';
  v_wholesaler uuid := '22222222-2222-4222-8222-222222222222';
  v_retailer   uuid := '33333333-3333-4333-8333-333333333333';
  v_product    uuid;
  v_count      bigint;
  v_min        numeric;
  v_max        numeric;
  v_text       text;
  v_state      text;
  v_role       text;
  v_owners     uuid[];
begin
  select id into v_product from public.products
   where name = 'RLS Fixture Purifier';

  -- (t2) set_dealer_role() in check (t) left the retailer fixture priced as a
  --      wholesaler. Put it back before the retailer checks run, or every one
  --      of them is really a second wholesaler check.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  perform public.set_dealer_role(v_retailer, 'retailer');
  select role::text into v_role from public.profiles where id = v_retailer;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    't2', 'owner: set_dealer_role() restores the retailer', 'retailer',
    v_role, v_role = 'retailer');

  -- =========================================================================
  -- u: the retailer half of the price-isolation guarantee.
  --    d1..d4 proved a wholesaler cannot reach the retail figure. Nothing
  --    proved the mirror, and the mirror is the one this phase ships.
  -- =========================================================================

  -- (u1) The whole view row for a retailer must not contain the wholesale
  --      figure anywhere -- not in a column, not in a jsonb blob, nowhere.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select to_jsonb(c)::text into v_text
    from public.catalog_view c where c.id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u1', 'retailer: wholesale figure absent from entire view row',
    'no 5000 in row',
    case when v_text like '%5000%' then 'LEAKED' else 'absent' end,
    v_text is not null and v_text not like '%5000%');

  -- (u2) At volume: EVERY price a retailer receives sits in the retail band.
  --      One row out of 500 landing in 1000..1499 fails this.
  perform set_config('role', 'authenticated', true);
  select count(*), min(price), max(price) into v_count, v_min, v_max
    from public.catalog_view where name like 'Volume Fixture %';
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u2', 'retailer: all 500 volume prices are retail-band',
    '500 rows in 90000..90499',
    v_count || ' rows in ' || coalesce(v_min::text, 'null') || '..'
      || coalesce(v_max::text, 'null'),
    v_count = 500 and v_min >= 90000 and v_max < 90500);

  -- (u3) And the mirror, so a view that simply returned the same column to
  --      everybody could not pass both.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*), min(price), max(price) into v_count, v_min, v_max
    from public.catalog_view where name like 'Volume Fixture %';
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u3', 'wholesaler: all 500 volume prices are wholesale-band',
    '500 rows in 1000..1499',
    v_count || ' rows in ' || coalesce(v_min::text, 'null') || '..'
      || coalesce(v_max::text, 'null'),
    v_count = 500 and v_min >= 1000 and v_max < 1500);

  -- (u4) catalog_images_view is the other way into the catalogue, and the
  --      brief names it explicitly. It must carry no price column at all.
  select string_agg(column_name, ', ' order by column_name) into v_text
    from information_schema.columns
   where table_schema = 'public' and table_name = 'catalog_images_view'
     and (column_name like '%price%' or column_name like '%mrp%');
  insert into rls_result values (
    'u4', 'catalog_images_view exposes no price column', 'none',
    coalesce(v_text, 'none'), v_text is null);

  -- (u5) A retailer naming wholesale_price on that view is stopped by the
  --      parser, not by a policy that could be worked around.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    execute 'select wholesale_price from public.catalog_images_view limit 1'
      into v_text;
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u5', 'retailer: SELECT wholesale_price FROM catalog_images_view',
    '42703 undefined_column', v_state, v_state = '42703');

  -- (u6) Joining the images view back to the base table is the obvious next
  --      attempt. products is empty for a dealer, so the join returns nothing
  --      rather than a price.
  perform set_config('role', 'authenticated', true);
  begin
    execute $q$
      select count(*)
        from public.catalog_images_view v
        join public.products p on p.id = v.product_id
    $q$ into v_count;
    v_state := v_count || ' rows';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u6', 'retailer: catalog_images_view JOIN products', '0 rows',
    v_state, v_state = '0 rows');

  -- (u7) Nor can a retailer read the base table through the view''s own
  --      product_id, one row at a time.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.products where id = v_product;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'u7', 'retailer: SELECT on products by id', '0 rows', v_count || ' rows',
    v_count = 0);

  -- =========================================================================
  -- v: no routine hands out a price, and no routine skips its own guard.
  -- =========================================================================

  -- (v1) Structural, and deliberately not a list of the routines that exist
  --      today: any function a dealer may execute that returns a column named
  --      like a price fails this, including one written next year.
  select string_agg(
           p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')',
           ', ' order by p.proname)
    into v_text
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'
     and has_function_privilege('authenticated', p.oid, 'execute')
     and (
       pg_get_function_result(p.oid) ~* '(price|mrp)'
       or pg_get_function_arguments(p.oid) ~* 'out +[a-z_]*(price|mrp)'
     );
  insert into rls_result values (
    'v1', 'no dealer-executable routine returns a price column', 'none',
    coalesce(v_text, 'none'), v_text is null);

  -- (v2) The same question asked of the views a dealer may select from.
  --      Views only, and by oid rather than by name: a dealer holds the plain
  --      table grant on products and is stopped by RLS instead, which v7 below
  --      checks separately, and information_schema resolves names against a
  --      search path that does not always contain what it lists.
  select string_agg(c.relname || '.' || a.attname, ', '
                    order by c.relname, a.attname)
    into v_text
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    join pg_attribute a on a.attrelid = c.oid
                       and a.attnum > 0 and not a.attisdropped
   where n.nspname = 'public'
     and c.relkind in ('v', 'm')
     and has_table_privilege('authenticated', c.oid, 'select')
     and (a.attname like '%wholesale%' or a.attname like '%retail%'
          or a.attname = 'mrp');
  insert into rls_result values (
    'v2', 'no dealer-readable view exposes a named price column', 'none',
    coalesce(v_text, 'none'), v_text is null);

  -- (v7) The two prices sit side by side on products, and a dealer holds the
  --      table grant. Row level security is the entire reason that is safe, so
  --      a build that shipped with it switched off would pass every behavioural
  --      check above only because nobody had disabled it yet.
  select string_agg(c.relname, ', ' order by c.relname) into v_text
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relname in ('products', 'product_images', 'profiles',
                       'scan_events', 'audit_log', 'business_settings')
     and not c.relrowsecurity;
  insert into rls_result values (
    'v7', 'row level security is enabled on every sensitive table', 'none off',
    coalesce(v_text || ' OFF', 'none off'), v_text is null);

  -- (v3) Every SECURITY DEFINER routine bypasses RLS by construction, so the
  --      is_owner() line inside its body is the only thing protecting it. The
  --      four auth helpers are exempt: they ARE the primitives, they answer
  --      only about the caller, and gating them on is_owner() would make every
  --      policy in the schema unevaluable.
  select string_agg(p.proname, ', ' order by p.proname) into v_text
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'
     and p.prosecdef
     and has_function_privilege('authenticated', p.oid, 'execute')
     and p.proname not in (
       'auth_role', 'auth_status', 'is_owner', 'is_approved'
     )
     and p.prosrc !~ 'is_owner\(\)';
  insert into rls_result values (
    'v3', 'every dealer-callable SECURITY DEFINER routine asserts is_owner()',
    'none', coalesce(v_text, 'none'), v_text is null);

  -- (v4) Behavioural backstop for v1: the one analytics routine that names
  --      products is called as a retailer and must refuse rather than return.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.top_scanned_products(3650, 500);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'v4', 'retailer: top_scanned_products() at volume',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (v5) recent_dealer_activity() and dealer_activity() were never covered.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.recent_dealer_activity(50);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'v5', 'retailer: recent_dealer_activity()',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (v6) dealer_activity() would otherwise tell one dealer how busy another is.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.dealer_activity(v_wholesaler);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'v6', 'retailer: dealer_activity() on another dealer',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (v8) Nothing anonymous executes anything.
  --
  --      This is the check that would have caught the hole 0019 closed. A
  --      Supabase project grants EXECUTE on every new function in `public` to
  --      anon and authenticated by default, and `revoke ... from public`
  --      removes only the implicit PUBLIC grant -- so every revoke in this
  --      schema was a no-op, and promote_owner(), which has no is_owner() line
  --      by design, was reachable over PostgREST with nothing but the anon key
  --      that ships inside the APK.
  select string_agg(p.proname, ', ' order by p.proname) into v_text
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'
     and has_function_privilege('anon', p.oid, 'execute');
  insert into rls_result values (
    'v8', 'no routine in public is executable by anon', 'none',
    coalesce(v_text, 'none'), v_text is null);

  -- (v9) The bootstrap routine specifically, named rather than left to v8: it
  --      is the one that hands out the owner role, and it is defined in
  --      seed.sql where a future edit would not be reviewed alongside a
  --      migration.
  select coalesce(
           string_agg(r.rolname, ', ' order by r.rolname), '') into v_text
    from pg_roles r
   where r.rolname in ('anon', 'authenticated')
     and to_regprocedure('public.promote_owner(text)') is not null
     and has_function_privilege(
           r.rolname, 'public.promote_owner(text)', 'execute');
  insert into rls_result values (
    'v9', 'promote_owner() is not executable by a client role', 'none',
    coalesce(nullif(v_text, ''), 'none'), coalesce(v_text, '') = '');

  -- (v10) And the audit writer, which is SECURITY DEFINER and so writes past
  --       policies that have no INSERT arm at all. A dealer holding this could
  --       forge entries into the owner's activity feed.
  select coalesce(
           string_agg(r.rolname, ', ' order by r.rolname), '') into v_text
    from pg_roles r
   where r.rolname in ('anon', 'authenticated')
     and has_function_privilege(
           r.rolname,
           'public.write_audit_log(text, text, uuid, jsonb)', 'execute');
  insert into rls_result values (
    'v10', 'write_audit_log() is not executable by a client role', 'none',
    coalesce(nullif(v_text, ''), 'none'), coalesce(v_text, '') = '');

  -- (v11) Product codes are printed onto physical labels and the column is
  --       unique, so a client able to wind the sequence backwards could stop
  --       the owner adding products at all.
  select coalesce(string_agg(r.rolname || ':' || g.priv, ', '
                             order by r.rolname, g.priv), '') into v_text
    from pg_roles r
    cross join (values ('USAGE'), ('SELECT'), ('UPDATE')) as g(priv)
   where r.rolname in ('anon', 'authenticated')
     and has_sequence_privilege(r.rolname, 'public.product_code_seq', g.priv);
  insert into rls_result values (
    'v11', 'product_code_seq is not reachable by a client role', 'none',
    coalesce(nullif(v_text, ''), 'none'), coalesce(v_text, '') = '');

  -- (v12) Defence in depth, checked behaviourally. v9 proves the grant is
  --       gone; this proves the body would refuse even if a later migration
  --       handed the grant back. Called as the session role rather than as
  --       `authenticated`, because with the grant correctly removed there is no
  --       other way to reach the body at all -- the guard is the thing under
  --       test here, not the grant.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  begin
    perform public.promote_owner('test-retailer@example.test');
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  insert into rls_result values (
    'v12', 'promote_owner() body refuses a non-owner once an owner exists',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (v13) ...and still bootstraps when there is no owner, which is the only
  --       job it has. A guard that refused everybody would pass v12 and make
  --       the project unusable on the day it is handed over.
  --
  --       EVERY owner has to go, not just the fixture one: seed.sql leaves a
  --       real owner behind, and with it still standing this would be testing
  --       v12 a second time.
  --
  --       PL/pgSQL has no ROLLBACK TO SAVEPOINT, so they are demoted and then
  --       put back by hand rather than by unwinding. Both updates run with the
  --       claims cleared, which is the no-JWT path
  --       guard_profile_privilege_columns() exempts for seeding.
  perform set_config('request.jwt.claims', '', true);
  select array_agg(id) into v_owners from public.profiles where role = 'owner';
  update public.profiles set role = 'wholesaler' where role = 'owner';
  begin
    perform public.promote_owner('test-owner@example.test');
    select role::text into v_role from public.profiles where id = v_owner;
    v_state := v_role;
  exception when others then
    v_state := sqlstate;
  end;
  update public.profiles
     set role = 'owner', status = 'approved'
   where id = any(v_owners);
  insert into rls_result values (
    'v13', 'promote_owner() still bootstraps when no owner exists', 'owner',
    v_state, v_state = 'owner');

  -- =========================================================================
  -- w: scan telemetry is write-only for dealers.
  -- =========================================================================

  -- (w1) A retailer reading the table gets nothing, at volume.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.scan_events;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w1', 'retailer: SELECT on scan_events', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (w2) So does a wholesaler. Two roles, because the policy is is_owner()
  --      and a policy written as "not retailer" would pass w1 and fail here.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.scan_events;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w2', 'wholesaler: SELECT on scan_events', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (w3) An aggregate is the way a leak would actually be phrased -- nobody
  --      asks for 4000 rows, they ask how many there are.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count
    from public.scan_events where scanned_by = v_retailer;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w3', 'wholesaler: COUNT of another dealer''s scans', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (w4) A dealer may still record their own scan. The feature depends on it,
  --      so proving the lock-out did not also break the write matters.
  perform set_config('role', 'authenticated', true);
  begin
    insert into public.scan_events (product_id, scanned_by, scanned_role, source)
    values (v_product, v_wholesaler, 'wholesaler', 'camera');
    v_state := 'inserted';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w4', 'wholesaler: INSERT own scan_event', 'inserted', v_state,
    v_state = 'inserted');

  -- (w5) But not one attributed to somebody else.
  perform set_config('role', 'authenticated', true);
  begin
    insert into public.scan_events (product_id, scanned_by, scanned_role, source)
    values (v_product, v_retailer, 'retailer', 'camera');
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w5', 'wholesaler: INSERT scan_event attributed to another dealer',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (w6) The owner reads the table, at volume. A policy that denied everybody
  --      would pass w1..w3 and be useless.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.scan_events;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'w6', 'owner: SELECT on scan_events', '4001 rows', v_count || ' rows',
    v_count = 4001);

  -- =========================================================================
  -- x: suspension takes effect on the very next request, in all three roles.
  --    Nothing is re-authenticated in between: the JWT a suspended account
  --    holds is still valid and still parses. Every policy re-reads the
  --    profile row, which is why the next statement already sees the change.
  -- =========================================================================

  -- (x1) A wholesaler, suspended mid-session, reads an empty catalogue. This
  --      is the quiet case: not an error, zero rows, which is why the client
  --      has a guard that re-reads the profile when the catalogue empties.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  perform public.suspend_dealer(v_wholesaler);
  perform set_config('role', 'none', true);

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_wholesaler, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.catalog_view;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x1', 'suspended wholesaler: SELECT on catalog_view', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (x2) And the write that DOES fail loudly, which is how the app finds out.
  perform set_config('role', 'authenticated', true);
  begin
    insert into public.scan_events (product_id, scanned_by, scanned_role, source)
    values (v_product, v_wholesaler, 'wholesaler', 'camera');
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x2', 'suspended wholesaler: INSERT into scan_events',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  -- (x3) The business details go dark too, so a suspended dealer cannot even
  --      keep printing the letterhead onto quotations.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.business_settings;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x3', 'suspended wholesaler: SELECT on business_settings', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (x4) The same for a retailer.
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  perform public.suspend_dealer(v_retailer);
  perform set_config('role', 'none', true);

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_retailer, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.catalog_view;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x4', 'suspended retailer: SELECT on catalog_view', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (x5) Including the images view, which has its own copy of the is_approved()
  --      qual and could have been missed.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.catalog_images_view;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x5', 'suspended retailer: SELECT on catalog_images_view', '0 rows',
    v_count || ' rows', v_count = 0);

  -- (x6) The owner is the third role, and the one it would be easy to forget:
  --      is_owner() requires status = 'approved', so a suspended owner loses
  --      every administrative routine rather than keeping them.
  --      Suspended by direct update, because suspend_dealer() refuses to
  --      suspend the caller -- which is itself the right behaviour -- and no
  --      other routine will touch an owner. The claims are cleared first so the
  --      update runs on the no-JWT path that guard_profile_privilege_columns()
  --      exempts and that seed.sql already uses; carrying the previous dealer's
  --      JWT into it would trip the guard, which is the guard working.
  --
  --      Suspending the account is the SETUP. The check is what the very next
  --      request does once the owner's own JWT is put back.
  perform set_config('request.jwt.claims', '', true);
  update public.profiles set status = 'suspended' where id = v_owner;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.dealer_counts();
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x6', 'suspended owner: dealer_counts()', '42501 insufficient_privilege',
    v_state, v_state = '42501');

  -- (x7) A suspended owner cannot read the catalogue master either, so the
  --      two prices are out of reach of a paused administrator account.
  perform set_config('role', 'authenticated', true);
  select count(*) into v_count from public.products;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x7', 'suspended owner: SELECT on products', '0 rows', v_count || ' rows',
    v_count = 0);

  -- (x8) And cannot re-approve themselves back out of it.
  perform set_config('role', 'authenticated', true);
  begin
    perform public.reactivate_dealer(v_owner);
    v_state := 'no error';
  exception when others then
    v_state := sqlstate;
  end;
  perform set_config('role', 'none', true);
  insert into rls_result values (
    'x8', 'suspended owner: reactivate_dealer() on self',
    '42501 insufficient_privilege', v_state, v_state = '42501');

  perform set_config('request.jwt.claims', '', true);
end
$phase3$;

\echo ''
\echo '================ RLS VERIFICATION ================'
select check_id            as "#",
       description,
       expected,
       actual,
       case when passed then 'PASS' else 'FAIL' end as result
  from rls_result
 order by check_id;
\echo ''

do $verdict$
declare
  v_failed int;
  v_total  int;
begin
  select count(*) filter (where not passed), count(*)
    into v_failed, v_total
    from rls_result;

  if v_failed > 0 then
    raise exception '% of % RLS checks FAILED', v_failed, v_total;
  end if;

  raise notice 'All % RLS checks passed.', v_total;
end
$verdict$;

rollback;
