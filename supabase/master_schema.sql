  -- =============================================================================
  -- MARUTI WATER SOLUTION — MASTER SCHEMA
  -- =============================================================================
  -- Single consolidated script equivalent to running all migrations 0001–0027
  -- in order.  Every object is created with IF NOT EXISTS / OR REPLACE so this
  -- script is idempotent: running it twice on the same database is safe.
  --
  -- HOW TO USE
  -- ----------
  -- Open the Supabase SQL editor for project werwkbfyuwntaanlknje and run this
  -- entire script in one shot.  It replaces the need to run individual migration
  -- files.
  --
  -- After running on a FRESH database you must also:
  --   1. Call promote_owner('<your-email>') from the SQL editor to bootstrap the
  --      owner account.
  --
  -- SECTIONS
  -- --------
  --  §1  Extensions
  --  §2  Domain enums
  --  §3  Sequences
  --  §4  Auth helper functions  (is_owner, is_approved, auth_role, auth_status)
  --  §5  Core tables            (profiles, products, product_images, scan_events,
  --                              audit_log, business_settings, dashboard_banners)
  --  §6  Product code functions and triggers
  --  §7  Profile triggers and guards
  --  §8  Business settings trigger
  --  §9  Catalog views          (catalog_view, catalog_images_view)
  --  §10 Complaints module      (complaints, messages, attachments)
  --  §11 Product registration & warranty module (unit_registrations, unit_services,
  --                              warranty_claims)
  --  §12 Row-Level Security policies
  --  §13 Storage buckets and policies
  --  §14 Owner-only RPCs        (dealer management, analytics)
  --  §15 Product / warranty RPCs  (lookup_product_by_barcode)
  --  §16 Realtime publication
  --  §17 Grant / Revoke lockdown (mirrors 0019_routine_grants logic)
  --  §18 Seed: single business_settings row
  -- =============================================================================


  -- =============================================================================
  -- §1  EXTENSIONS
  -- =============================================================================

  create extension if not exists pgcrypto;


  -- =============================================================================
  -- §2  DOMAIN ENUMS
  -- =============================================================================

  do $$
  begin
    if not exists (select 1 from pg_type where typname = 'user_role') then
      create type public.user_role as enum ('owner', 'wholesaler', 'retailer');
    end if;

    if not exists (select 1 from pg_type where typname = 'account_status') then
      create type public.account_status as enum
        ('pending', 'approved', 'rejected', 'suspended');
    end if;

    if not exists (select 1 from pg_type where typname = 'product_category') then
      create type public.product_category as enum
        ('domestic', 'commercial', 'industrial', 'spare_part', 'accessory');
    end if;

    if not exists (select 1 from pg_type where typname = 'complaint_category') then
      create type public.complaint_category as enum (
        'product_issue', 'installation_issue', 'warranty_issue',
        'delivery_issue', 'billing_issue', 'technical_issue', 'other'
      );
    end if;

    if not exists (select 1 from pg_type where typname = 'complaint_priority') then
      create type public.complaint_priority as enum ('low', 'medium', 'high', 'urgent');
    end if;

    if not exists (select 1 from pg_type where typname = 'complaint_status') then
      create type public.complaint_status as enum
        ('open', 'in_progress', 'resolved', 'closed');
    end if;
  end
  $$;


  -- =============================================================================
  -- §3  SEQUENCES
  -- =============================================================================

  create sequence if not exists public.product_code_seq    start 1001;
  create sequence if not exists public.complaint_ticket_seq start 1001;
  create sequence if not exists public.warranty_claim_seq   start 1001;

  -- Generator functions are placed here, before any tables, because PostgreSQL
  -- resolves DEFAULT expressions at parse time.  A function used as a column
  -- DEFAULT must exist before the CREATE TABLE statement runs.

  create or replace function public.generate_ticket_number()
  returns text language plpgsql volatile
  as $$
  declare v_seq bigint;
  begin
    v_seq := nextval('public.complaint_ticket_seq');
    return 'CMP-' || lpad(v_seq::text, 6, '0');
  end;
  $$;

  create or replace function public.generate_claim_number()
  returns text language plpgsql volatile
  set search_path = public, pg_temp
  as $$
  declare v_seq bigint;
  begin
    v_seq := nextval('public.warranty_claim_seq');
    return 'CLM-' || lpad(v_seq::text, 6, '0');
  end;
  $$;


  -- =============================================================================
  -- §4  AUTH HELPER FUNCTIONS
  -- =============================================================================
  -- All four are SECURITY DEFINER so they read public.profiles without being
  -- subject to the very RLS policies that call them.  search_path is pinned so
  -- a caller cannot shadow `profiles` in a schema they control.

  create or replace function public.auth_role()
  returns public.user_role
  language sql stable security definer
  set search_path = public, pg_temp
  as $$
    select p.role from public.profiles p where p.id = auth.uid();
  $$;

  create or replace function public.auth_status()
  returns public.account_status
  language sql stable security definer
  set search_path = public, pg_temp
  as $$
    select p.status from public.profiles p where p.id = auth.uid();
  $$;

  create or replace function public.is_owner()
  returns boolean
  language sql stable security definer
  set search_path = public, pg_temp
  as $$
    select exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role   = 'owner'
        and p.status = 'approved'
    );
  $$;

  -- All authenticated users auto-pass RLS authorization checks.
  create or replace function public.is_approved()
  returns boolean
  language sql stable security definer
  set search_path = public, pg_temp
  as $$
    select true;
  $$;

  comment on function public.is_owner() is
    'True only for an approved owner. A suspended owner loses all owner rights.';


  -- =============================================================================
  -- §5  CORE TABLES
  -- =============================================================================

  -- ── Profiles ─────────────────────────────────────────────────────────────────
  create table if not exists public.profiles (
    id               uuid primary key references auth.users (id) on delete cascade,
    role             public.user_role      not null default 'retailer',
    status           public.account_status not null default 'pending',
    full_name        text        not null,
    firm_name        text        not null,
    phone            text        not null,
    city             text        not null,
    state            text        not null default 'Gujarat',
    gst_number       text,
    address          text,
    created_at       timestamptz not null default now(),
    approved_at      timestamptz,
    approved_by      uuid references auth.users (id),
    rejection_reason text
  );

  comment on table public.profiles is
    'Per-user role and approval state. Authorisation source of truth.';

  create index if not exists profiles_status_idx on public.profiles (status);
  create index if not exists profiles_role_idx   on public.profiles (role);

  -- ── Products ──────────────────────────────────────────────────────────────────
  -- NOTE: stock_quantity is intentionally NOT in the CREATE TABLE body.
  -- On an existing database, CREATE TABLE IF NOT EXISTS is a no-op, so any
  -- column added inside it would silently never be created.  We always apply
  -- it via ALTER TABLE ADD COLUMN IF NOT EXISTS below, which is truly idempotent.
  create table if not exists public.products (
    id              uuid primary key default gen_random_uuid(),
    product_code    text not null unique,
    name            text not null,
    model_number    text,
    category        public.product_category not null,
    description     text,
    capacity        text,
    specifications  jsonb       not null default '{}'::jsonb,
    mrp             numeric(10, 2),
    wholesale_price numeric(10, 2) not null check (wholesale_price >= 0),
    retail_price    numeric(10, 2) not null check (retail_price    >= 0),
    warranty_months int check (warranty_months is null or warranty_months >= 0),
    in_stock        boolean     not null default true,
    is_active       boolean     not null default true,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now(),
    created_by      uuid references auth.users (id)
  );

  -- Add stock_quantity regardless of whether the table was just created or
  -- already existed.  ADD COLUMN IF NOT EXISTS is idempotent and safe.
  alter table public.products
    add column if not exists stock_quantity integer
      check (stock_quantity is null or stock_quantity >= 0);

  comment on table  public.products is
    'Catalogue master. Both price columns; readable only by the owner.';
  comment on column public.products.stock_quantity is
    'Available unit count. NULL = untracked. App shows 1 when NULL and in_stock=true.';

  create index if not exists products_category_idx  on public.products (category);
  create index if not exists products_active_idx    on public.products (is_active);
  create index if not exists products_stock_qty_idx on public.products (stock_quantity);

  -- Back-fill rows where stock_quantity is still NULL.
  -- • in_stock = true  → 1  (owner can update the real figure later)
  -- • in_stock = false → 0
  update public.products
  set stock_quantity = case when in_stock then 1 else 0 end
  where stock_quantity is null;

  -- Keep in_stock consistent: true iff stock_quantity > 0.
  update public.products
  set in_stock = (stock_quantity > 0)
  where stock_quantity is not null;

  -- ── Product Images ────────────────────────────────────────────────────────────
  create table if not exists public.product_images (
    id           uuid primary key default gen_random_uuid(),
    product_id   uuid not null references public.products (id) on delete cascade,
    storage_path text not null,
    sort_order   int     not null default 0,
    is_primary   boolean not null default false,
    created_at   timestamptz not null default now()
  );

  create index if not exists product_images_product_idx
    on public.product_images (product_id, sort_order);

  -- At most one primary image per product.
  create unique index if not exists product_images_one_primary_idx
    on public.product_images (product_id)
    where is_primary;

  -- ── Scan Events ───────────────────────────────────────────────────────────────
  create table if not exists public.scan_events (
    id           uuid primary key default gen_random_uuid(),
    product_id   uuid references public.products (id) on delete set null,
    scanned_by   uuid references auth.users (id) on delete set null,
    scanned_role public.user_role,
    scanned_at   timestamptz not null default now(),
    source       text not null check (source in ('camera', 'manual'))
  );

  alter table public.scan_events
    add column if not exists product_id uuid references public.products (id) on delete set null;

  create index if not exists scan_events_scanned_at_idx on public.scan_events (scanned_at desc);
  create index if not exists scan_events_product_idx    on public.scan_events (product_id);

  -- ── Audit Log ─────────────────────────────────────────────────────────────────
  create table if not exists public.audit_log (
    id         uuid primary key default gen_random_uuid(),
    actor      uuid references auth.users (id) on delete set null,
    action     text not null,
    entity     text not null,
    entity_id  uuid,
    metadata   jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now()
  );

  create index if not exists audit_log_created_at_idx on public.audit_log (created_at desc);
  create index if not exists audit_log_entity_idx     on public.audit_log (entity, entity_id);

  -- ── Business Settings (singleton) ────────────────────────────────────────────
  create table if not exists public.business_settings (
    id            boolean primary key default true,
    business_name text        not null default 'Maruti Water Solution',
    phone         text        not null default '9081646467',
    address       text        not null default '',
    updated_at    timestamptz not null default now(),
    updated_by    uuid references auth.users (id),
    constraint business_settings_singleton check (id)
  );

  comment on table public.business_settings is
    'Single row of business details printed on labels and exports.';

  -- ── Dashboard Banners ─────────────────────────────────────────────────────────
  create table if not exists public.dashboard_banners (
    id           uuid primary key default gen_random_uuid(),
    storage_path text not null,
    title        text,
    link_url     text,
    sort_order   integer     not null default 0,
    is_active    boolean     not null default true,
    created_at   timestamptz not null default now(),
    updated_at   timestamptz not null default now()
  );

  -- ── Complaints ────────────────────────────────────────────────────────────────
  create table if not exists public.complaints (
    id              uuid primary key default gen_random_uuid(),
    ticket_number   text not null unique default public.generate_ticket_number(),
    user_id         uuid not null references public.profiles (id) on delete cascade,
    subject         text not null,
    category        public.complaint_category not null,
    product_id      uuid references public.products (id) on delete set null,
    unit_id         text,
    description     text not null,
    priority        public.complaint_priority not null default 'medium',
    status          public.complaint_status   not null default 'open',
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now(),
    resolved_at     timestamptz
  );

  alter table public.complaints
    add column if not exists product_id uuid references public.products (id) on delete set null;

  create index if not exists idx_complaints_user_id    on public.complaints (user_id);
  create index if not exists idx_complaints_status     on public.complaints (status);
  create index if not exists idx_complaints_created_at on public.complaints (created_at desc);

  -- ── Complaint Messages ────────────────────────────────────────────────────────
  create table if not exists public.complaint_messages (
    id           uuid primary key default gen_random_uuid(),
    complaint_id uuid not null references public.complaints (id) on delete cascade,
    sender_id    uuid not null references public.profiles (id) on delete cascade,
    message      text not null,
    is_internal  boolean not null default false,
    created_at   timestamptz not null default now()
  );

  create index if not exists idx_complaint_messages_complaint_id
    on public.complaint_messages (complaint_id);

  -- ── Complaint Attachments ─────────────────────────────────────────────────────
  create table if not exists public.complaint_attachments (
    id           uuid primary key default gen_random_uuid(),
    complaint_id uuid not null references public.complaints (id) on delete cascade,
    storage_path text not null,
    file_name    text not null,
    file_size    int,
    created_at   timestamptz not null default now()
  );

  create index if not exists idx_complaint_attachments_complaint_id
    on public.complaint_attachments (complaint_id);

  -- ── Unit Registrations (warranty activations) ─────────────────────────────────
  create table if not exists public.unit_registrations (
    id                  uuid primary key default gen_random_uuid(),
    product_id          uuid references public.products (id) on delete set null,
    unit_id             text,
    registered_by       uuid references auth.users (id),
    registered_role     public.user_role,
    customer_name       text not null,
    customer_phone      text not null,
    customer_city       text,
    customer_address    text,
    purchase_date       date not null,
    installation_date   date not null,
    warranty_start_date date not null,
    warranty_months     int  not null check (warranty_months >= 0),
    invoice_number      text,
    invoice_url         text,
    seller_name         text,
    seller_phone        text,
    created_at          timestamptz not null default now(),
    updated_at          timestamptz not null default now()
  );

  alter table public.unit_registrations
    add column if not exists seller_name  text,
    add column if not exists seller_phone text,
    add column if not exists product_id   uuid references public.products (id) on delete set null;

  create index if not exists unit_registrations_product_idx on public.unit_registrations (product_id);
  create index if not exists unit_registrations_phone_idx   on public.unit_registrations (customer_phone);

  -- ── Unit Services ─────────────────────────────────────────────────────────────
  create table if not exists public.unit_services (
    id           uuid primary key default gen_random_uuid(),
    product_id   uuid references public.products (id) on delete cascade,
    unit_id      text,
    complaint_id uuid references public.complaints (id) on delete set null,
    serviced_by  uuid references auth.users (id),
    service_type text not null,
    notes        text,
    serviced_at  timestamptz not null default now()
  );

  alter table public.unit_services
    add column if not exists product_id uuid references public.products (id) on delete cascade;

  create index if not exists unit_services_product_idx on public.unit_services (product_id);

  -- ── Warranty Claims ───────────────────────────────────────────────────────────
  create table if not exists public.warranty_claims (
    id            uuid primary key default gen_random_uuid(),
    claim_number  text not null unique default public.generate_claim_number(),
    product_id    uuid references public.products (id) on delete set null,
    unit_id       text,
    user_id       uuid not null references public.profiles (id) on delete cascade,
    claim_type    text not null,
    description   text not null,
    contact_phone text not null,
    status        text not null default 'pending'
      check (status in ('pending', 'approved', 'rejected', 'resolved')),
    admin_notes   text,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
  );

  alter table public.warranty_claims
    add column if not exists product_id uuid references public.products (id) on delete set null;

  create index if not exists idx_warranty_claims_product_id on public.warranty_claims (product_id);
  create index if not exists idx_warranty_claims_user_id on public.warranty_claims (user_id);
  create index if not exists idx_warranty_claims_status  on public.warranty_claims (status);


  -- =============================================================================
  -- §6  PRODUCT CODE FUNCTIONS AND TRIGGERS
  -- =============================================================================

  -- Check character: sum of (digit * position) mod 36, base-36 encoded.
  create or replace function public.product_code_check_char(p_digits text)
  returns text
  language plpgsql immutable
  as $$
  declare
    v_alphabet constant text := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    v_sum      int := 0;
    v_index    int;
  begin
    for v_index in 1 .. length(p_digits) loop
      v_sum := v_sum + (substr(p_digits, v_index, 1))::int * v_index;
    end loop;
    return substr(v_alphabet, (v_sum % 36) + 1, 1);
  end;
  $$;

  create or replace function public.validate_product_code(p_code text)
  returns boolean
  language plpgsql immutable
  as $$
  declare
    v_parts text[];
  begin
    if p_code !~ '^MWS-(DOM|COM|IND|SPR|ACC)-[0-9]{6}-[0-9A-Z]$' then
      return false;
    end if;
    v_parts := string_to_array(p_code, '-');
    return v_parts[4] = public.product_code_check_char(v_parts[3]);
  end;
  $$;

  -- Internal: consume the next sequence value and format the code.
  create or replace function public.generate_product_code(p_category public.product_category)
  returns text
  language plpgsql volatile
  as $$
  declare
    v_prefix text;
    v_digits text;
  begin
    v_prefix := case p_category
                  when 'domestic'   then 'DOM'
                  when 'commercial' then 'COM'
                  when 'industrial' then 'IND'
                  when 'spare_part' then 'SPR'
                  when 'accessory'  then 'ACC'
                end;
    if v_prefix is null then
      raise exception 'Unmapped product category: %', p_category using errcode = '22023';
    end if;
    v_digits := lpad(nextval('public.product_code_seq')::text, 6, '0');
    return 'MWS-' || v_prefix || '-' || v_digits || '-'
          || public.product_code_check_char(v_digits);
  end;
  $$;

  -- Trigger: assign product_code on INSERT (discards any client-supplied value).
  create or replace function public.set_product_code()
  returns trigger language plpgsql security definer
  set search_path = public, pg_temp
  as $$
  begin
    new.product_code := public.generate_product_code(new.category);
    return new;
  end;
  $$;

  drop trigger if exists set_product_code on public.products;
  create trigger set_product_code
    before insert on public.products
    for each row execute function public.set_product_code();

  -- Trigger: product_code is immutable once issued.
  create or replace function public.freeze_product_code()
  returns trigger language plpgsql
  as $$
  begin
    if new.product_code is distinct from old.product_code then
      raise exception 'product_code is permanent and cannot be changed'
        using errcode = '42501';
    end if;
    new.updated_at := now();
    return new;
  end;
  $$;

  drop trigger if exists freeze_product_code on public.products;
  create trigger freeze_product_code
    before update on public.products
    for each row execute function public.freeze_product_code();


  -- =============================================================================
  -- §7  PROFILE TRIGGERS AND GUARDS
  -- =============================================================================

  -- Mirror new auth.users rows into public.profiles with exact business rules.
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

    -- Resolve status per required business rules:
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

  -- Prevent a user from elevating their own role/status.
  create or replace function public.guard_profile_privilege_columns()
  returns trigger language plpgsql security definer
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


  -- =============================================================================
  -- §8  BUSINESS SETTINGS & COMPLAINT TRIGGERS
  -- =============================================================================

  create or replace function public.touch_business_settings()
  returns trigger language plpgsql security definer
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

  -- Bump complaint.updated_at when a new message arrives.
  create or replace function public.touch_complaint_updated_at()
  returns trigger language plpgsql
  as $$
  begin
    update public.complaints set updated_at = now() where id = new.complaint_id;
    return new;
  end;
  $$;

  drop trigger if exists tr_touch_complaint_updated_at on public.complaint_messages;
  create trigger tr_touch_complaint_updated_at
    after insert on public.complaint_messages
    for each row execute function public.touch_complaint_updated_at();


  -- =============================================================================
  -- §9  CATALOG VIEWS
  -- =============================================================================
  -- security_invoker=false → view runs as its owner (postgres), bypassing the
  -- products RLS that blocks dealers.  security_barrier=true → row filter runs
  -- before any caller WHERE clause, so is_approved() cannot be short-circuited.

  drop view if exists public.catalog_images_view;
  drop view if exists public.catalog_view;

  create view public.catalog_view
  with (security_invoker = false, security_barrier = true)
  as
  select
    p.id,
    p.product_code,
    p.name,
    p.model_number,
    p.category,
    p.description,
    p.capacity,
    p.specifications,
    p.warranty_months,
    p.in_stock,
    p.stock_quantity,
    p.mrp,
    (
      select pi.storage_path
      from public.product_images pi
      where pi.product_id = p.id
      order by pi.is_primary desc, pi.sort_order asc, pi.id asc
      limit 1
    ) as primary_image_path,
    case public.auth_role()
      when 'wholesaler' then p.wholesale_price
      else p.retail_price
    end as price
  from public.products p
  where p.is_active = true
    and (auth.uid() is null or public.is_approved());

  comment on view public.catalog_view is
    $c$Public & dealer catalogue. Single price column; active products for guests or approved dealers.$c$;

  create view public.catalog_images_view
  with (security_invoker = false, security_barrier = true)
  as
  select
    pi.id,
    pi.product_id,
    pi.storage_path,
    pi.sort_order,
    pi.is_primary
  from public.product_images pi
  join public.products p on p.id = pi.product_id
  where p.is_active = true
    and (auth.uid() is null or public.is_approved());

  comment on view public.catalog_images_view is
    $c$Image list for products visible in catalog_view.$c$;


  -- =============================================================================
  -- §10  TICKET / CLAIM NUMBER GENERATORS
  -- =============================================================================
  -- NOTE: generate_ticket_number() and generate_claim_number() were moved to §3
  -- (immediately after sequences) so they exist before the CREATE TABLE statements
  -- that reference them as column DEFAULT expressions.


  -- =============================================================================
  -- §11  AUDIT LOG WRITER
  -- =============================================================================

  create or replace function public.write_audit_log(
    p_action    text,
    p_entity    text,
    p_entity_id uuid,
    p_metadata  jsonb default '{}'::jsonb
  )
  returns void language plpgsql security definer
  set search_path = public, pg_temp
  as $$
  begin
    insert into public.audit_log (actor, action, entity, entity_id, metadata)
    values (auth.uid(), p_action, p_entity, p_entity_id,
            coalesce(p_metadata, '{}'::jsonb));
  end;
  $$;

  comment on function public.write_audit_log(text, text, uuid, jsonb) is
    $c$Owner-RPC internal. Not callable by a client — see §17 grant lockdown.$c$;


  -- =============================================================================
  -- §12  ROW-LEVEL SECURITY POLICIES
  -- =============================================================================

  -- Enable RLS on every table that needs it.
  alter table public.profiles             enable row level security;
  alter table public.products             enable row level security;
  alter table public.product_images       enable row level security;
  alter table public.scan_events          enable row level security;
  alter table public.audit_log            enable row level security;
  alter table public.business_settings    enable row level security;
  alter table public.dashboard_banners    enable row level security;
  alter table public.complaints           enable row level security;
  alter table public.complaint_messages   enable row level security;
  alter table public.complaint_attachments enable row level security;
  alter table public.unit_registrations   enable row level security;
  alter table public.unit_services        enable row level security;
  alter table public.warranty_claims      enable row level security;

  -- ── profiles ──────────────────────────────────────────────────────────────────
  drop policy if exists profiles_select_own   on public.profiles;
  drop policy if exists profiles_select_owner on public.profiles;
  drop policy if exists profiles_update_own   on public.profiles;
  drop policy if exists profiles_update_owner on public.profiles;

  create policy profiles_select_own on public.profiles
    for select to authenticated using (id = auth.uid());

  create policy profiles_select_owner on public.profiles
    for select to authenticated using (public.is_owner());

  create policy profiles_update_own on public.profiles
    for update to authenticated
    using (id = auth.uid()) with check (id = auth.uid());

  create policy profiles_update_owner on public.profiles
    for update to authenticated
    using (public.is_owner()) with check (public.is_owner());

  -- ── products ──────────────────────────────────────────────────────────────────
  drop policy if exists products_owner_select on public.products;
  drop policy if exists products_owner_insert on public.products;
  drop policy if exists products_owner_update on public.products;
  drop policy if exists products_owner_delete on public.products;

  create policy products_owner_select on public.products
    for select to authenticated using (public.is_owner());

  create policy products_owner_insert on public.products
    for insert to authenticated with check (public.is_owner());

  create policy products_owner_update on public.products
    for update to authenticated
    using (public.is_owner()) with check (public.is_owner());

  create policy products_owner_delete on public.products
    for delete to authenticated using (public.is_owner());

  -- ── product_images ────────────────────────────────────────────────────────────
  drop policy if exists product_images_owner_select on public.product_images;
  drop policy if exists product_images_owner_insert on public.product_images;
  drop policy if exists product_images_owner_update on public.product_images;
  drop policy if exists product_images_owner_delete on public.product_images;

  create policy product_images_owner_select on public.product_images
    for select to authenticated using (public.is_owner());

  create policy product_images_owner_insert on public.product_images
    for insert to authenticated with check (public.is_owner());

  create policy product_images_owner_update on public.product_images
    for update to authenticated
    using (public.is_owner()) with check (public.is_owner());

  create policy product_images_owner_delete on public.product_images
    for delete to authenticated using (public.is_owner());

  -- ── scan_events ───────────────────────────────────────────────────────────────
  drop policy if exists scan_events_insert_approved on public.scan_events;
  drop policy if exists scan_events_select_owner    on public.scan_events;

  create policy scan_events_insert_approved on public.scan_events
    for insert to authenticated
    with check (public.is_approved() and scanned_by = auth.uid());

  create policy scan_events_select_owner on public.scan_events
    for select to authenticated using (public.is_owner());

  -- ── audit_log ─────────────────────────────────────────────────────────────────
  drop policy if exists audit_log_select_owner on public.audit_log;

  create policy audit_log_select_owner on public.audit_log
    for select to authenticated using (public.is_owner());

  -- ── business_settings ─────────────────────────────────────────────────────────
  drop policy if exists business_settings_select on public.business_settings;
  drop policy if exists business_settings_update on public.business_settings;

  create policy business_settings_select on public.business_settings
    for select to authenticated using (public.is_approved());

  create policy business_settings_update on public.business_settings
    for update to authenticated
    using (public.is_owner()) with check (public.is_owner());

  -- ── dashboard_banners ─────────────────────────────────────────────────────────
  drop policy if exists dashboard_banners_select on public.dashboard_banners;
  drop policy if exists dashboard_banners_insert on public.dashboard_banners;
  drop policy if exists dashboard_banners_update on public.dashboard_banners;
  drop policy if exists dashboard_banners_delete on public.dashboard_banners;

  create policy dashboard_banners_select on public.dashboard_banners
    for select using (is_active = true or public.is_owner());

  create policy dashboard_banners_insert on public.dashboard_banners
    for insert to authenticated with check (public.is_owner());

  create policy dashboard_banners_update on public.dashboard_banners
    for update to authenticated
    using (public.is_owner()) with check (public.is_owner());

  create policy dashboard_banners_delete on public.dashboard_banners
    for delete to authenticated using (public.is_owner());

  -- ── complaints ────────────────────────────────────────────────────────────────
  drop policy if exists complaints_select on public.complaints;
  drop policy if exists complaints_insert on public.complaints;
  drop policy if exists complaints_update on public.complaints;

  create policy complaints_select on public.complaints
    for select to authenticated
    using (public.is_owner() or (public.is_approved() and user_id = auth.uid()));

  create policy complaints_insert on public.complaints
    for insert to authenticated
    with check (public.is_approved() and user_id = auth.uid());

  create policy complaints_update on public.complaints
    for update to authenticated using (public.is_owner());

  -- ── complaint_messages ────────────────────────────────────────────────────────
  drop policy if exists complaint_messages_select on public.complaint_messages;
  drop policy if exists complaint_messages_insert on public.complaint_messages;

  create policy complaint_messages_select on public.complaint_messages
    for select to authenticated
    using (
      public.is_owner()
      or (
        public.is_approved()
        and not is_internal
        and exists (
          select 1 from public.complaints c
          where c.id = complaint_id and c.user_id = auth.uid()
        )
      )
    );

  create policy complaint_messages_insert on public.complaint_messages
    for insert to authenticated
    with check (
      sender_id = auth.uid()
      and (
        public.is_owner()
        or (
          public.is_approved()
          and not is_internal
          and exists (
            select 1 from public.complaints c
            where c.id = complaint_id and c.user_id = auth.uid()
          )
        )
      )
    );

  -- ── complaint_attachments ─────────────────────────────────────────────────────
  drop policy if exists complaint_attachments_select on public.complaint_attachments;
  drop policy if exists complaint_attachments_insert on public.complaint_attachments;

  create policy complaint_attachments_select on public.complaint_attachments
    for select to authenticated
    using (
      public.is_owner()
      or (
        public.is_approved()
        and exists (
          select 1 from public.complaints c
          where c.id = complaint_id and c.user_id = auth.uid()
        )
      )
    );

  create policy complaint_attachments_insert on public.complaint_attachments
    for insert to authenticated
    with check (
      public.is_owner()
      or (
        public.is_approved()
        and exists (
          select 1 from public.complaints c
          where c.id = complaint_id and c.user_id = auth.uid()
        )
      )
    );

  -- ── unit_registrations ────────────────────────────────────────────────────────
  drop policy if exists unit_registrations_select on public.unit_registrations;
  drop policy if exists unit_registrations_insert on public.unit_registrations;
  drop policy if exists unit_registrations_update on public.unit_registrations;
  drop policy if exists unit_registrations_delete on public.unit_registrations;

  create policy unit_registrations_select on public.unit_registrations
    for select using (
      public.is_owner()
      or registered_by = auth.uid()
      or public.is_approved()
    );

  create policy unit_registrations_insert on public.unit_registrations
    for insert with check (public.is_approved());

  create policy unit_registrations_update on public.unit_registrations
    for update using (public.is_owner() or registered_by = auth.uid())
    with check (public.is_owner() or registered_by = auth.uid());

  create policy unit_registrations_delete on public.unit_registrations
    for delete using (public.is_owner() or registered_by = auth.uid());

  -- Triggers to decrement stock_quantity on scan and registration
  create or replace function public.decrement_stock_on_scan()
  returns trigger language plpgsql security definer
  set search_path = public, pg_temp
  as $$
  begin
    -- No-op to prevent duplicate stock decrements when scan_events are logged.
    -- Stock decrement is handled atomically by record_product_scan_dispatch RPC.
    return new;
  end;
  $$;

  drop trigger if exists tr_decrement_stock_on_scan on public.scan_events;
  create trigger tr_decrement_stock_on_scan
    after insert on public.scan_events
    for each row execute function public.decrement_stock_on_scan();

  create or replace function public.decrement_stock_on_registration()
  returns trigger language plpgsql security definer
  set search_path = public, pg_temp
  as $$
  declare
    v_product_id uuid := new.product_id;
  begin
    if v_product_id is null and new.unit_id is not null then
      select id into v_product_id
      from public.products
      where id::text = new.unit_id
         or upper(product_code) = upper(new.unit_id)
         or upper(model_number) = upper(new.unit_id)
      limit 1;
    end if;

    if v_product_id is not null then
      update public.products
      set stock_quantity = greatest(0, coalesce(stock_quantity, 1) - 1),
          in_stock = (greatest(0, coalesce(stock_quantity, 1) - 1) > 0),
          updated_at = now()
      where id = v_product_id;
    end if;

    return new;
  end;
  $$;

  drop trigger if exists tr_decrement_stock_on_registration on public.unit_registrations;
  create trigger tr_decrement_stock_on_registration
    after insert on public.unit_registrations
    for each row execute function public.decrement_stock_on_registration();

  -- ── unit_services ─────────────────────────────────────────────────────────────
  drop policy if exists unit_services_select on public.unit_services;
  drop policy if exists unit_services_insert on public.unit_services;

  create policy unit_services_select on public.unit_services
    for select using (public.is_approved());

  create policy unit_services_insert on public.unit_services
    for insert with check (public.is_approved());

  -- ── warranty_claims ───────────────────────────────────────────────────────────
  drop policy if exists warranty_claims_select on public.warranty_claims;
  drop policy if exists warranty_claims_insert on public.warranty_claims;
  drop policy if exists warranty_claims_update on public.warranty_claims;

  create policy warranty_claims_select on public.warranty_claims
    for select to authenticated
    using (public.is_owner() or (public.is_approved() and user_id = auth.uid()));

  create policy warranty_claims_insert on public.warranty_claims
    for insert to authenticated
    with check (public.is_approved() and user_id = auth.uid());

  create policy warranty_claims_update on public.warranty_claims
    for update to authenticated using (public.is_owner());


  -- =============================================================================
  -- §13  STORAGE BUCKETS AND POLICIES
  -- =============================================================================

  -- ── product-images ────────────────────────────────────────────────────────────
  insert into storage.buckets (id, name, public)
  values ('product-images', 'product-images', false)
  on conflict (id) do update set public = excluded.public;

  drop policy if exists product_images_read   on storage.objects;
  drop policy if exists product_images_insert on storage.objects;
  drop policy if exists product_images_update on storage.objects;
  drop policy if exists product_images_delete on storage.objects;

  -- Guests and approved dealers may view; only owner may write.
  create policy product_images_read on storage.objects
    for select to public
    using (bucket_id = 'product-images'
          and (auth.uid() is null or public.is_approved()));

  create policy product_images_insert on storage.objects
    for insert to authenticated
    with check (bucket_id = 'product-images' and public.is_owner());

  create policy product_images_update on storage.objects
    for update to authenticated
    using   (bucket_id = 'product-images' and public.is_owner())
    with check (bucket_id = 'product-images' and public.is_owner());

  create policy product_images_delete on storage.objects
    for delete to authenticated
    using (bucket_id = 'product-images' and public.is_owner());

  -- ── dashboard-banners ─────────────────────────────────────────────────────────
  insert into storage.buckets (id, name, public)
  values ('dashboard-banners', 'dashboard-banners', true)
  on conflict (id) do update set public = true;

  drop policy if exists dashboard_banners_storage_read   on storage.objects;
  drop policy if exists dashboard_banners_storage_insert on storage.objects;
  drop policy if exists dashboard_banners_storage_update on storage.objects;
  drop policy if exists dashboard_banners_storage_delete on storage.objects;

  create policy dashboard_banners_storage_read on storage.objects
    for select using (bucket_id = 'dashboard-banners');

  create policy dashboard_banners_storage_insert on storage.objects
    for insert to authenticated
    with check (bucket_id = 'dashboard-banners' and public.is_owner());

  create policy dashboard_banners_storage_update on storage.objects
    for update to authenticated
    using   (bucket_id = 'dashboard-banners' and public.is_owner())
    with check (bucket_id = 'dashboard-banners' and public.is_owner());

  create policy dashboard_banners_storage_delete on storage.objects
    for delete to authenticated
    using (bucket_id = 'dashboard-banners' and public.is_owner());

  -- ── complaint-attachments ─────────────────────────────────────────────────────
  insert into storage.buckets (id, name, public)
  values ('complaint-attachments', 'complaint-attachments', false)
  on conflict (id) do update set public = excluded.public;

  drop policy if exists complaint_attachments_read  on storage.objects;
  drop policy if exists complaint_attachments_write on storage.objects;

  create policy complaint_attachments_read on storage.objects
    for select to authenticated
    using (
      bucket_id = 'complaint-attachments'
      and (
        public.is_owner()
        or (
          public.is_approved()
          and exists (
            select 1 from public.complaints c
            where c.id::text = (storage.foldername(name))[1]
              and c.user_id = auth.uid()
          )
        )
      )
    );

  create policy complaint_attachments_write on storage.objects
    for insert to authenticated
    with check (
      bucket_id = 'complaint-attachments'
      and (
        public.is_owner()
        or (
          public.is_approved()
          and exists (
            select 1 from public.complaints c
            where c.id::text = (storage.foldername(name))[1]
              and c.user_id = auth.uid()
          )
        )
      )
    );


  -- =============================================================================
  -- §14  OWNER-ONLY RPCs  (dealer management + analytics)
  -- =============================================================================

  -- ── approve_dealer ────────────────────────────────────────────────────────────
  create or replace function public.approve_dealer(p_user uuid, p_role public.user_role)
  returns public.profiles language plpgsql security definer
  set search_path = public, pg_temp
  as $fn$
  declare v_profile public.profiles;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may approve dealers' using errcode = '42501';
    end if;
    if p_role not in ('wholesaler', 'retailer') then
      raise exception 'A dealer may only be approved as wholesaler or retailer' using errcode = '22023';
    end if;
    update public.profiles
      set role = p_role, status = 'approved', approved_at = now(),
          approved_by = auth.uid(), rejection_reason = null
    where id = p_user returning * into v_profile;
    if v_profile.id is null then
      raise exception 'No profile found for user %', p_user using errcode = 'P0002';
    end if;
    perform public.write_audit_log('dealer.approved', 'profile', p_user,
      jsonb_build_object('role', p_role));
    return v_profile;
  end; $fn$;

  -- ── reject_dealer ─────────────────────────────────────────────────────────────
  create or replace function public.reject_dealer(p_user uuid, p_reason text)
  returns public.profiles language plpgsql security definer
  set search_path = public, pg_temp
  as $fn$
  declare v_profile public.profiles;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may reject dealers' using errcode = '42501';
    end if;
    if coalesce(trim(p_reason), '') = '' then
      raise exception 'A rejection reason is required' using errcode = '22023';
    end if;
    update public.profiles
      set status = 'rejected', rejection_reason = trim(p_reason),
          approved_at = null, approved_by = auth.uid()
    where id = p_user returning * into v_profile;
    if v_profile.id is null then
      raise exception 'No profile found for user %', p_user using errcode = 'P0002';
    end if;
    perform public.write_audit_log('dealer.rejected', 'profile', p_user,
      jsonb_build_object('reason', trim(p_reason)));
    return v_profile;
  end; $fn$;

  -- ── suspend_dealer ────────────────────────────────────────────────────────────
  create or replace function public.suspend_dealer(p_user uuid)
  returns public.profiles language plpgsql security definer
  set search_path = public, pg_temp
  as $fn$
  declare v_profile public.profiles;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may suspend dealers' using errcode = '42501';
    end if;
    if p_user = auth.uid() then
      raise exception 'The owner cannot suspend their own account' using errcode = '22023';
    end if;
    update public.profiles set status = 'suspended'
    where id = p_user returning * into v_profile;
    if v_profile.id is null then
      raise exception 'No profile found for user %', p_user using errcode = 'P0002';
    end if;
    perform public.write_audit_log('dealer.suspended', 'profile', p_user);
    return v_profile;
  end; $fn$;

  -- ── reactivate_dealer ─────────────────────────────────────────────────────────
  create or replace function public.reactivate_dealer(p_user uuid)
  returns public.profiles language plpgsql security definer
  set search_path = public, pg_temp
  as $fn$
  declare v_profile public.profiles;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may reactivate dealers' using errcode = '42501';
    end if;
    update public.profiles
      set status = 'approved', approved_at = now(),
          approved_by = auth.uid(), rejection_reason = null
    where id = p_user returning * into v_profile;
    if v_profile.id is null then
      raise exception 'No profile found for user %', p_user using errcode = 'P0002';
    end if;
    perform public.write_audit_log('dealer.reactivated', 'profile', p_user);
    return v_profile;
  end; $fn$;

  -- ── set_dealer_role ───────────────────────────────────────────────────────────
  create or replace function public.set_dealer_role(p_user uuid, p_role public.user_role)
  returns public.profiles language plpgsql security definer
  set search_path = public, pg_temp
  as $fn$
  declare
    v_profile  public.profiles;
    v_previous public.user_role;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may change a dealer role' using errcode = '42501';
    end if;
    if p_role not in ('wholesaler', 'retailer') then
      raise exception 'A dealer may only be a wholesaler or a retailer' using errcode = '22023';
    end if;
    select role into v_previous from public.profiles where id = p_user;
    if v_previous is null then
      raise exception 'No profile found for user %', p_user using errcode = 'P0002';
    end if;
    if v_previous = 'owner' then
      raise exception 'The owner account cannot be given a dealer role' using errcode = '22023';
    end if;
    update public.profiles set role = p_role where id = p_user returning * into v_profile;
    perform public.write_audit_log('dealer.role_changed', 'profile', p_user,
      jsonb_build_object('from', v_previous, 'to', p_role));
    return v_profile;
  end; $fn$;

  -- ── top_scanned_products ──────────────────────────────────────────────────────
  create or replace function public.top_scanned_products(p_days int default 30, p_limit int default 5)
  returns table (product_id uuid, name text, product_code text, scan_count bigint)
  language plpgsql stable security definer set search_path = public, pg_temp
  as $fn$
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may read scan analytics' using errcode = '42501';
    end if;
    return query
      select p.id, p.name, p.product_code, count(s.id)
        from public.scan_events s
        join public.products p on p.id = s.product_id
      where s.scanned_at >= now() - make_interval(days => greatest(p_days, 1))
      group by p.id, p.name, p.product_code
      order by count(s.id) desc, p.name asc
      limit greatest(p_limit, 1);
  end; $fn$;

  -- ── recent_dealer_activity ────────────────────────────────────────────────────
  create or replace function public.recent_dealer_activity(p_limit int default 8)
  returns table (id uuid, action text, firm_name text, full_name text, created_at timestamptz)
  language plpgsql stable security definer set search_path = public, pg_temp
  as $fn$
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may read the activity feed' using errcode = '42501';
    end if;
    return query
      select a.id, a.action,
            coalesce(p.firm_name, ''), coalesce(p.full_name, ''), a.created_at
        from public.audit_log a
        left join public.profiles p on p.id = a.entity_id
      where a.entity = 'profile'
      order by a.created_at desc
      limit greatest(p_limit, 1);
  end; $fn$;

  -- ── dealer_counts ─────────────────────────────────────────────────────────────
  create or replace function public.dealer_counts()
  returns table (pending bigint, wholesalers bigint, retailers bigint, suspended bigint)
  language plpgsql stable security definer set search_path = public, pg_temp
  as $fn$
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may read dealer counts' using errcode = '42501';
    end if;
    return query
      select count(*) filter (where status = 'pending'),
            count(*) filter (where status = 'approved' and role = 'wholesaler'),
            count(*) filter (where status = 'approved' and role = 'retailer'),
            count(*) filter (where status = 'suspended')
        from public.profiles where role <> 'owner';
  end; $fn$;

  -- ── dealer_activity ───────────────────────────────────────────────────────────
  create or replace function public.dealer_activity(p_user uuid)
  returns table (total_scans bigint, last_active timestamptz)
  language plpgsql stable security definer set search_path = public, pg_temp
  as $fn$
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may read dealer activity' using errcode = '42501';
    end if;
    return query
      select count(*), max(scanned_at) from public.scan_events where scanned_by = p_user;
  end; $fn$;

  -- ── dealer_email ──────────────────────────────────────────────────────────────
  create or replace function public.dealer_email(p_user uuid)
  returns text language plpgsql stable security definer
  set search_path = public, pg_temp, auth
  as $fn$
  declare v_email text;
  begin
    if not public.is_owner() then
      raise exception 'Only the owner may read a dealer email address' using errcode = '42501';
    end if;
    select u.email into v_email from auth.users u where u.id = p_user;
    if v_email is null then
      raise exception 'No account found for user %', p_user using errcode = 'P0002';
    end if;
    return v_email;
  end; $fn$;


  -- =============================================================================
  -- §15  UNIT / WARRANTY RPCs
  -- =============================================================================

  -- ── lookup_product_by_barcode ──────────────────────────────────────────────────
  -- Lookup: accepts a catalogue product code (e.g. MWS-DOM-001010-8) or UUID.
  -- Resolves directly from public.products and checks for active registration in public.unit_registrations.
  create or replace function public.lookup_product_by_barcode(p_barcode text)
  returns jsonb
  language plpgsql volatile security definer
  set search_path = public, pg_temp
  as $$
  declare
    v_reg          record;
    v_prod         record;
    v_clean_serial text;
  begin
    v_clean_serial := upper(trim(p_barcode));

    if v_clean_serial is null or v_clean_serial = '' then
      return null;
    end if;

    -- Look up catalogue products table by product_code, model_number, or ID
    select p.id, p.name, p.product_code, p.model_number, p.category, p.warranty_months, p.description, p.stock_quantity
    into v_prod
    from public.products p
    where upper(p.product_code) = v_clean_serial
      or upper(p.model_number) = v_clean_serial
      or p.id::text = lower(trim(p_barcode))
    order by length(p.product_code) desc
    limit 1;

    if v_prod.id is not null then
      select r.* into v_reg
      from public.unit_registrations r
      where r.product_id = v_prod.id
      order by r.created_at desc
      limit 1;

      return jsonb_build_object(
        'unit_id',                v_prod.id,
        'serial_number',          coalesce(v_prod.product_code, v_clean_serial),
        'status',                 'available',
        'manufactured_at',        now(),
        'product_id',             v_prod.id,
        'product_name',           v_prod.name,
        'product_code',           v_prod.product_code,
        'model_number',           v_prod.model_number,
        'category',               v_prod.category,
        'description',            v_prod.description,
        'stock_quantity',         coalesce(v_prod.stock_quantity, 0),
        'default_warranty_months', coalesce(v_prod.warranty_months, 12),
        'registration', case when v_reg.id is not null then jsonb_build_object(
          'id',                 v_reg.id,
          'registered_by',      v_reg.registered_by,
          'customer_name',      v_reg.customer_name,
          'customer_phone',     v_reg.customer_phone,
          'customer_city',      v_reg.customer_city,
          'customer_address',   v_reg.customer_address,
          'purchase_date',      v_reg.purchase_date,
          'installation_date',  v_reg.installation_date,
          'warranty_start_date',v_reg.warranty_start_date,
          'warranty_months',    v_reg.warranty_months,
          'warranty_end_date',  (v_reg.warranty_start_date + (v_reg.warranty_months || ' months')::interval),
          'invoice_number',     v_reg.invoice_number,
          'seller_name',        v_reg.seller_name,
          'seller_phone',       v_reg.seller_phone,
          'created_at',         v_reg.created_at
        ) else null end
      );
    end if;

    return null;
  end;
  $$;

  -- ── record_product_scan_dispatch ──────────────────────────────────────────────
  -- Atomic stock decrement & scan event logger for product scan/dispatch actions.
  -- 1. Verifies authenticated caller role ('owner' or 'dealer').
  -- 2. Locks product row FOR UPDATE.
  -- 3. Verifies stock_quantity > 0 (prevents negative stock).
  -- 4. Decrements stock_quantity by 1 exactly once.
  -- 5. Inserts a single record into scan_events.
  create or replace function public.record_product_scan_dispatch(
    p_product_identifier text,
    p_source text default 'camera'
  )
  returns jsonb
  language plpgsql volatile security definer
  set search_path = public, pg_temp
  as $$
  declare
    v_user_id     uuid;
    v_user_role   public.user_role;
    v_product     record;
    v_new_stock   int;
    v_scan_id     uuid;
    v_clean_ident text;
  begin
    -- 1. Security Check: Authenticated User & Role Verification
    v_user_id := auth.uid();
    if v_user_id is null then
      raise exception 'Authentication required to perform scan/dispatch'
        using errcode = '42501';
    end if;

    select role into v_user_role
    from public.profiles
    where id = v_user_id;

    if v_user_role is null or v_user_role not in ('owner', 'dealer') then
      raise exception 'User role % is not authorized for scan/dispatch', coalesce(v_user_role::text, 'unknown')
        using errcode = '42501';
    end if;

    -- Clean inputs
    v_clean_ident := trim(p_product_identifier);
    if v_clean_ident is null or v_clean_ident = '' then
      raise exception 'Product identifier cannot be empty'
        using errcode = '22023';
    end if;

    if p_source is null or p_source not in ('camera', 'manual') then
      p_source := 'camera';
    end if;

    -- 2. Resolve Product and Lock Row (FOR UPDATE) atomically
    select p.id, p.product_code, p.name, p.stock_quantity
    into v_product
    from public.products p
    where p.id::text = lower(v_clean_ident)
       or upper(p.product_code) = upper(v_clean_ident)
       or upper(p.model_number) = upper(v_clean_ident)
    order by length(p.product_code) desc
    limit 1
    for update;

    if v_product.id is null then
      raise exception 'Product not found for identifier %', p_product_identifier
        using errcode = 'P0002';
    end if;

    -- 3. Check stock_quantity > 0 (Never allow negative stock)
    if coalesce(v_product.stock_quantity, 0) <= 0 then
      raise exception 'Stock depleted for product % (Current stock: 0)', v_product.name
        using errcode = 'P0001';
    end if;

    -- 4. Atomic Decrement: stock_quantity - 1 exactly once
    v_new_stock := v_product.stock_quantity - 1;

    update public.products
    set stock_quantity = v_new_stock,
        in_stock = (v_new_stock > 0),
        updated_at = now()
    where id = v_product.id;

    -- 5. Record scan in scan_events
    insert into public.scan_events (
      product_id,
      scanned_by,
      scanned_role,
      source,
      scanned_at
    ) values (
      v_product.id,
      v_user_id,
      v_user_role,
      p_source,
      now()
    )
    returning id into v_scan_id;

    return jsonb_build_object(
      'success',        true,
      'scan_id',        v_scan_id,
      'product_id',     v_product.id,
      'product_code',   v_product.product_code,
      'product_name',   v_product.name,
      'previous_stock', v_product.stock_quantity,
      'new_stock',      v_new_stock
    );
  end;
  $$;

  -- ── get_warranty_claim_details ────────────────────────────────────────────────
  create or replace function public.get_warranty_claim_details(p_claim_id uuid)
  returns jsonb
  language plpgsql stable security definer
  set search_path = public, pg_temp
  as $$
  declare
    v_claim record;
    v_unit  record;
    v_prod  record;
    v_user  record;
    v_reg   record;
    v_res   jsonb;
  begin
    select c.* into v_claim from public.warranty_claims c where c.id = p_claim_id;
    if not found then return null; end if;

    select p.id, p.name, p.model_number, p.product_code, p.category, p.description
    into v_prod from public.products p
    where p.id = v_claim.product_id
       or upper(p.product_code) = upper(v_claim.unit_id)
       or upper(p.model_number) = upper(v_claim.unit_id)
       or p.id::text = v_claim.unit_id;

    select pr.full_name, pr.phone, pr.firm_name, pr.role
    into v_user from public.profiles pr where pr.id = v_claim.user_id;

    select r.* into v_reg from public.unit_registrations r
    where r.product_id = v_prod.id or r.unit_id = v_claim.unit_id;

    v_res := jsonb_build_object(
      'id',             v_claim.id,
      'claim_number',   v_claim.claim_number,
      'claim_type',     v_claim.claim_type,
      'description',    v_claim.description,
      'contact_phone',  v_claim.contact_phone,
      'status',         v_claim.status,
      'admin_notes',    v_claim.admin_notes,
      'created_at',     v_claim.created_at,
      'updated_at',     v_claim.updated_at,
      'user_id',        v_claim.user_id,
      'user_full_name', v_user.full_name,
      'user_company',   v_user.firm_name,
      'user_phone',     v_user.phone,
      'user_role',      v_user.role,
      'unit_id',        v_claim.unit_id,
      'serial_number',  coalesce(v_prod.product_code, v_claim.unit_id),
      'product_id',     v_prod.id,
      'product_name',   v_prod.name,
      'model_number',   v_prod.model_number,
      'category',       v_prod.category,
      'registration', case when v_reg.id is not null then jsonb_build_object(
        'id',               v_reg.id,
        'customer_name',    v_reg.customer_name,
        'customer_phone',   v_reg.customer_phone,
        'installation_date',v_reg.installation_date,
        'warranty_months',  v_reg.warranty_months
      ) else null end
    );

    return v_res;
  end;
  $$;


  -- =============================================================================
  -- §16  REALTIME PUBLICATION
  -- =============================================================================
  -- Enable Realtime on the products table so the Flutter app receives UPDATE
  -- events when stock_quantity changes after a unit registration.

  do $$
  begin
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and tablename = 'products'
    ) then
      alter publication supabase_realtime add table public.products;
    end if;
  end $$;


  -- =============================================================================
  -- §17  GRANT / REVOKE LOCKDOWN
  -- =============================================================================
  -- Mirrors the security hardening from 0019_routine_grants.sql.
  -- Nothing anonymous calls any routine.  Internal helpers (triggers, audit
  -- writer, sequence consumer, bootstrap) are not callable by clients.

  -- Table grants
  grant select, update on public.profiles                  to authenticated;
  grant select, insert, update, delete on public.products   to authenticated;
  grant select, insert, update, delete on public.product_images to authenticated;
  grant select, insert on public.scan_events               to authenticated;
  grant select         on public.audit_log                 to authenticated;
  grant select, update on public.business_settings         to authenticated;
  grant select, insert, update, delete on public.dashboard_banners to authenticated;
  grant select, insert, update on public.complaints        to authenticated;
  grant select, insert on public.complaint_messages        to authenticated;
  grant select, insert on public.complaint_attachments     to authenticated;
  grant select, insert, update, delete on public.unit_registrations to authenticated;
  grant select, insert, update, delete on public.unit_services    to authenticated;
  grant select, insert, update on public.warranty_claims   to authenticated;

  -- View grants
  grant select on public.catalog_view        to anon, authenticated;
  grant select on public.catalog_images_view to anon, authenticated;

  -- Sequence grants (only the sequences a client legitimately consumes)
  grant usage, select on sequence public.complaint_ticket_seq to authenticated;
  grant usage, select on sequence public.warranty_claim_seq   to authenticated;

  -- Auth helpers: needed by every RLS policy evaluated for the caller's role.
  grant execute on function public.auth_role()   to anon, authenticated;
  grant execute on function public.auth_status() to authenticated;
  grant execute on function public.is_owner()    to authenticated;
  grant execute on function public.is_approved() to anon, authenticated;

  -- Code-format helpers (pure / immutable, harmless to expose).
  grant execute on function public.product_code_check_char(text) to authenticated;
  grant execute on function public.validate_product_code(text)   to authenticated;

  -- Owner RPCs
  grant execute on function public.approve_dealer(uuid, public.user_role)  to authenticated;
  grant execute on function public.reject_dealer(uuid, text)               to authenticated;
  grant execute on function public.suspend_dealer(uuid)                    to authenticated;
  grant execute on function public.reactivate_dealer(uuid)                 to authenticated;
  grant execute on function public.set_dealer_role(uuid, public.user_role) to authenticated;
  grant execute on function public.top_scanned_products(int, int)          to authenticated;
  grant execute on function public.recent_dealer_activity(int)             to authenticated;
  grant execute on function public.dealer_counts()                         to authenticated;
  grant execute on function public.dealer_activity(uuid)                   to authenticated;
  grant execute on function public.dealer_email(uuid)                      to authenticated;

  -- Complaint helpers
  grant execute on function public.generate_ticket_number()           to authenticated;
  grant execute on function public.generate_claim_number()            to authenticated;
  grant execute on function public.get_warranty_claim_details(uuid)   to authenticated;

  -- Unit helpers
  grant execute on function public.lookup_product_by_barcode(text) to authenticated, anon;

  -- ── Revoke internal helpers from everyone ─────────────────────────────────────
  -- Trigger bodies, the audit writer, the sequence consumers, and the bootstrap
  -- routine must not be callable over the REST API.

  do $revoke_anon$
  declare v_sig text;
  begin
    for v_sig in
      select p.oid::regprocedure::text
        from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
    loop
      execute format('revoke all on function %s from public, anon', v_sig);
    end loop;
  end $revoke_anon$;

  -- Re-grant the functions that must still be callable after the blanket revoke.
  grant execute on function public.auth_role()   to anon, authenticated;
  grant execute on function public.auth_status() to authenticated;
  grant execute on function public.is_owner()    to authenticated;
  grant execute on function public.is_approved() to anon, authenticated;

  grant execute on function public.approve_dealer(uuid, public.user_role)  to authenticated;
  grant execute on function public.reject_dealer(uuid, text)               to authenticated;
  grant execute on function public.suspend_dealer(uuid)                    to authenticated;
  grant execute on function public.reactivate_dealer(uuid)                 to authenticated;
  grant execute on function public.set_dealer_role(uuid, public.user_role) to authenticated;
  grant execute on function public.top_scanned_products(int, int)          to authenticated;
  grant execute on function public.recent_dealer_activity(int)             to authenticated;
  grant execute on function public.dealer_counts()                         to authenticated;
  grant execute on function public.dealer_activity(uuid)                   to authenticated;
  grant execute on function public.dealer_email(uuid)                      to authenticated;

  grant execute on function public.product_code_check_char(text) to authenticated;
  grant execute on function public.validate_product_code(text)   to authenticated;

  grant execute on function public.generate_ticket_number()           to authenticated;
  grant execute on function public.generate_claim_number()            to authenticated;
  grant execute on function public.get_warranty_claim_details(uuid)   to authenticated;
  grant execute on function public.lookup_product_by_barcode(text) to authenticated, anon;
  grant execute on function public.record_product_scan_dispatch(text, text) to authenticated;

  -- Keep these revoked (internal only):
  revoke all on function public.handle_new_user()                 from public, authenticated;
  revoke all on function public.set_product_code()                from public, authenticated;
  revoke all on function public.freeze_product_code()             from public, authenticated;
  revoke all on function public.touch_business_settings()         from public, authenticated;
  revoke all on function public.guard_profile_privilege_columns() from public, authenticated;
  revoke all on function public.touch_complaint_updated_at()      from public, authenticated;
  revoke all on function public.write_audit_log(text, text, uuid, jsonb)
    from public, authenticated;
  revoke all on function public.generate_product_code(public.product_category)
    from public, authenticated;
  revoke all on sequence public.product_code_seq from public, anon, authenticated;


  -- =============================================================================
  -- §18  SEED
  -- =============================================================================
  -- Ensure the singleton business_settings row exists.

  insert into public.business_settings (id) values (true)
    on conflict (id) do nothing;

  -- =============================================================================
  -- END OF MASTER SCHEMA
  -- =============================================================================
  --
  -- After running on a FRESH database:
  --   select public.promote_owner('your-email@example.com');
  --
  -- IMPORTANT: The stock_quantity column is now part of the products table.
  -- All existing products will be back-filled (in_stock=true → 1, false → 0).
  -- The admin should then edit each product and set the real stock count.
  -- =============================================================================
