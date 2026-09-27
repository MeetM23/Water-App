-- =============================================================================
-- MARUTI WATER SOLUTION — MASTER SCHEMA
-- =============================================================================
-- Single consolidated script equivalent to running all migrations 0001–0027
-- in order.  Every object is created with IF NOT EXISTS / OR REPLACE so this
-- script is idempotent: running it twice on the same database is safe.
--
-- HOW TO USE
-- ----------
-- Open the Supabase SQL editor for your project and run this entire script
-- in one shot. It replaces the need to run individual migration files.
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
--  §5  Core tables            (profiles, products, product_qr_labels, product_images, scan_events,
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
--  §15 Product / warranty / QR RPCs (allocate_product_qr_labels, fetch_product_qr_labels, lookup_product_by_barcode)
--  §16 Realtime publication
--  §17 Grant / Revoke lockdown
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
returns text language plpgsql volatile security definer
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

create index if not exists profiles_status_idx on public.profiles (status);
create index if not exists profiles_role_idx   on public.profiles (role);

-- ── Products ──────────────────────────────────────────────────────────────────
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

alter table public.products
  add column if not exists stock_quantity integer
    check (stock_quantity is null or stock_quantity >= 0);

create index if not exists products_category_idx  on public.products (category);
create index if not exists products_active_idx    on public.products (is_active);
create index if not exists products_stock_qty_idx on public.products (stock_quantity);

update public.products
set stock_quantity = case when in_stock then 1 else 0 end
where stock_quantity is null;

update public.products
set in_stock = (stock_quantity > 0)
where stock_quantity is not null;

-- ── Product Label Sequences ───────────────────────────────────────────────────
create table if not exists public.product_label_sequences (
  product_id          uuid primary key references public.products (id) on delete cascade,
  prefix              text not null,
  start_number        integer not null default 1 check (start_number >= 0),
  pad_length          integer not null default 3 check (pad_length >= 1),
  last_sequence       integer not null default 0 check (last_sequence >= 0),
  total_generated     integer not null default 0 check (total_generated >= 0),
  unprinted_count     integer not null default 0 check (unprinted_count >= 0),
  last_allocated_labels jsonb not null default '[]'::jsonb,
  updated_at          timestamptz not null default now()
);

-- ── Product QR Labels (Authoritative persistent QR mappings) ─────────────────
create table if not exists public.product_qr_labels (
  id              uuid primary key default gen_random_uuid(),
  product_id      uuid not null references public.products (id) on delete cascade,
  qr_code         text not null unique,
  sequence_number integer not null,
  created_at      timestamptz not null default now(),
  constraint uq_product_qr_labels_product_seq unique (product_id, sequence_number)
);

create index if not exists idx_product_qr_labels_product_id on public.product_qr_labels (product_id);
create index if not exists idx_product_qr_labels_qr_code    on public.product_qr_labels (qr_code);

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
  description     text not null,
  priority        public.complaint_priority not null default 'medium',
  status          public.complaint_status   not null default 'open',
  contact_phone   text not null,
  contact_email   text,
  admin_notes     text,
  resolved_at     timestamptz,
  resolved_by     uuid references auth.users (id),
  resolution_notes text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists complaints_user_idx   on public.complaints (user_id);
create index if not exists complaints_status_idx on public.complaints (status);

-- ── Complaint Messages ────────────────────────────────────────────────────────
create table if not exists public.complaint_messages (
  id           uuid primary key default gen_random_uuid(),
  complaint_id uuid not null references public.complaints (id) on delete cascade,
  sender_id    uuid not null references auth.users (id),
  message      text not null,
  is_internal  boolean not null default false,
  created_at   timestamptz not null default now()
);

create index if not exists complaint_messages_complaint_idx
  on public.complaint_messages (complaint_id, created_at);

-- ── Complaint Attachments ─────────────────────────────────────────────────────
create table if not exists public.complaint_attachments (
  id           uuid primary key default gen_random_uuid(),
  complaint_id uuid not null references public.complaints (id) on delete cascade,
  storage_path text not null,
  file_name    text not null,
  file_size    int,
  content_type text,
  created_at   timestamptz not null default now()
);

create index if not exists complaint_attachments_complaint_idx
  on public.complaint_attachments (complaint_id);

-- ── Unit Registrations ────────────────────────────────────────────────────────
create table if not exists public.unit_registrations (
  id                  uuid primary key default gen_random_uuid(),
  unit_id             text,
  product_id          uuid references public.products (id) on delete set null,
  registered_by       uuid not null references public.profiles (id),
  customer_name       text not null,
  customer_phone      text not null,
  customer_city       text not null,
  customer_address    text not null,
  purchase_date       date not null,
  installation_date   date not null,
  warranty_start_date date not null,
  warranty_months     int  not null check (warranty_months >= 0),
  warranty_end_date   date not null,
  invoice_number      text,
  seller_name         text,
  seller_phone        text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists unit_registrations_unit_idx    on public.unit_registrations (unit_id);
create index if not exists unit_registrations_product_idx on public.unit_registrations (product_id);
create index if not exists unit_registrations_phone_idx   on public.unit_registrations (customer_phone);

-- ── Unit Services ─────────────────────────────────────────────────────────────
create table if not exists public.unit_services (
  id              uuid primary key default gen_random_uuid(),
  unit_id         text not null,
  service_type    text not null,
  service_date    date not null,
  technician_name text,
  technician_phone text,
  notes           text,
  cost            numeric(10, 2) check (cost is null or cost >= 0),
  created_at      timestamptz not null default now()
);

create index if not exists unit_services_unit_idx on public.unit_services (unit_id);

-- ── Warranty Claims ───────────────────────────────────────────────────────────
create table if not exists public.warranty_claims (
  id              uuid primary key default gen_random_uuid(),
  claim_number    text not null unique default public.generate_claim_number(),
  user_id         uuid not null references public.profiles (id) on delete cascade,
  unit_id         text not null,
  product_id      uuid references public.products (id) on delete set null,
  claim_type      text not null check (claim_type in ('replacement', 'repair', 'refund', 'missing_part', 'other')),
  description     text not null,
  contact_phone   text not null,
  status          text not null default 'submitted' check (status in ('submitted', 'under_review', 'approved', 'rejected', 'in_repair', 'completed')),
  admin_notes     text,
  resolved_at     timestamptz,
  resolved_by     uuid references auth.users (id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists warranty_claims_user_idx   on public.warranty_claims (user_id);
create index if not exists warranty_claims_unit_idx   on public.warranty_claims (unit_id);
create index if not exists warranty_claims_status_idx on public.warranty_claims (status);


-- =============================================================================
-- §6  PRODUCT CODE FUNCTIONS AND TRIGGERS
-- =============================================================================

create or replace function public.product_code_check_char(p_digits text)
returns text language plpgsql immutable as $$
declare
  v_sum int := 0;
  v_len int := length(p_digits);
  v_mod int;
  c char;
begin
  for i in 1..v_len loop
    c := substr(p_digits, i, 1);
    v_sum := v_sum + (ascii(c) - 48) * (v_len - i + 1);
  end loop;
  v_mod := v_sum % 36;
  if v_mod < 10 then
    return chr(48 + v_mod);
  else
    return chr(55 + v_mod);
  end if;
end;
$$;

create or replace function public.generate_product_code(p_category public.product_category)
returns text language plpgsql volatile as $$
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

create or replace function public.set_product_code()
returns trigger language plpgsql security definer
set search_path = public, pg_temp
as $$
begin
  if new.product_code is null or trim(new.product_code) = '' then
    new.product_code := public.generate_product_code(new.category);
  else
    new.product_code := trim(new.product_code);
  end if;
  return new;
end;
$$;

drop trigger if exists set_product_code on public.products;
create trigger set_product_code
  before insert on public.products
  for each row execute function public.set_product_code();

create or replace function public.freeze_product_code()
returns trigger language plpgsql as $$
begin
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
  v_role := case lower(coalesce(v_metadata ->> 'role', ''))
              when 'owner' then 'owner'::public.user_role
              when 'wholesaler' then 'wholesaler'::public.user_role
              else 'retailer'::public.user_role
            end;

  v_status := case
                when v_role = 'owner'      then 'approved'::public.account_status
                when v_role = 'retailer'   then 'approved'::public.account_status
                when v_role = 'wholesaler' then 'pending'::public.account_status
                else 'pending'::public.account_status
              end;

  v_name  := coalesce(nullif(trim(v_metadata ->> 'full_name'), ''), 'New User');
  v_firm  := coalesce(nullif(trim(v_metadata ->> 'firm_name'), ''), v_name);
  v_phone := coalesce(nullif(trim(v_metadata ->> 'phone'),     ''), '');
  v_city  := coalesce(nullif(trim(v_metadata ->> 'city'),      ''), 'Ahmedabad');
  v_state := coalesce(nullif(trim(v_metadata ->> 'state'),     ''), 'Gujarat');

  insert into public.profiles (
    id, role, status, full_name, firm_name, phone, city, state,
    approved_at
  )
  values (
    new.id, v_role, v_status, v_name, v_firm, v_phone, v_city, v_state,
    case when v_status = 'approved' then now() else null end
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- =============================================================================
-- §8  BUSINESS SETTINGS TRIGGER
-- =============================================================================

create or replace function public.touch_business_settings()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end;
$$;

drop trigger if exists business_settings_touch on public.business_settings;
create trigger business_settings_touch
  before update on public.business_settings
  for each row execute function public.touch_business_settings();


-- =============================================================================
-- §9  CATALOG VIEWS
-- =============================================================================

drop view if exists public.catalog_images_view cascade;
drop view if exists public.catalog_view cascade;

create or replace view public.catalog_view as
select
  p.id,
  p.product_code,
  p.name,
  p.model_number,
  p.category,
  p.description,
  p.capacity,
  p.specifications,
  p.mrp,
  case
    when public.is_owner() then p.wholesale_price
    when public.auth_role() = 'wholesaler' then p.wholesale_price
    else p.retail_price
  end as price,
  p.wholesale_price,
  p.retail_price,
  p.warranty_months,
  p.in_stock,
  p.is_active,
  p.stock_quantity,
  p.created_at,
  p.updated_at,
  (
    select pi.storage_path
    from public.product_images pi
    where pi.product_id = p.id
    order by pi.is_primary desc, pi.sort_order asc
    limit 1
  ) as primary_image_path
from public.products p
where p.is_active = true
  and (auth.uid() is null or public.is_approved());

create or replace view public.catalog_images_view as
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


-- =============================================================================
-- §10  AUDIT LOG WRITER
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


-- =============================================================================
-- §11  ROW-LEVEL SECURITY POLICIES
-- =============================================================================

alter table public.profiles             enable row level security;
alter table public.products             enable row level security;
alter table public.product_qr_labels    enable row level security;
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

-- ── profiles ──
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

-- ── products ──
drop policy if exists products_select       on public.products;
drop policy if exists products_owner_insert on public.products;
drop policy if exists products_owner_update on public.products;
drop policy if exists products_owner_delete on public.products;

create policy products_select on public.products
  for select to authenticated, anon
  using (
    public.is_owner()
    or (is_active = true and (auth.uid() is null or public.is_approved()))
  );

create policy products_owner_insert on public.products
  for insert to authenticated with check (public.is_owner());

create policy products_owner_update on public.products
  for update to authenticated
  using (public.is_owner()) with check (public.is_owner());

create policy products_owner_delete on public.products
  for delete to authenticated using (public.is_owner());

-- ── product_qr_labels (Owner only direct table access) ──
drop policy if exists product_qr_labels_owner_all on public.product_qr_labels;
drop policy if exists product_qr_labels_select    on public.product_qr_labels;
drop policy if exists product_qr_labels_insert    on public.product_qr_labels;
drop policy if exists product_qr_labels_update    on public.product_qr_labels;
drop policy if exists product_qr_labels_delete    on public.product_qr_labels;

create policy product_qr_labels_owner_all on public.product_qr_labels
  for all to authenticated
  using (public.is_owner())
  with check (public.is_owner());

-- ── product_images ──
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

-- ── scan_events ──
drop policy if exists scan_events_insert_approved on public.scan_events;
drop policy if exists scan_events_select_owner    on public.scan_events;

create policy scan_events_insert_approved on public.scan_events
  for insert to authenticated
  with check (public.is_approved() and scanned_by = auth.uid());

create policy scan_events_select_owner on public.scan_events
  for select to authenticated using (public.is_owner());

-- ── audit_log ──
drop policy if exists audit_log_select_owner on public.audit_log;
create policy audit_log_select_owner on public.audit_log
  for select to authenticated using (public.is_owner());

-- ── business_settings ──
drop policy if exists business_settings_select on public.business_settings;
drop policy if exists business_settings_update on public.business_settings;

create policy business_settings_select on public.business_settings
  for select to authenticated using (public.is_approved());

create policy business_settings_update on public.business_settings
  for update to authenticated
  using (public.is_owner()) with check (public.is_owner());

-- ── dashboard_banners ──
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

-- ── complaints ──
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

-- ── complaint_messages ──
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

-- ── complaint_attachments ──
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

-- ── unit_registrations ──
drop policy if exists unit_registrations_select on public.unit_registrations;
drop policy if exists unit_registrations_insert on public.unit_registrations;
drop policy if exists unit_registrations_update on public.unit_registrations;
drop policy if exists unit_registrations_delete on public.unit_registrations;

create policy unit_registrations_select on public.unit_registrations
  for select using (
    public.is_owner()
    or registered_by = auth.uid()
  );

create policy unit_registrations_insert on public.unit_registrations
  for insert with check (public.is_approved());

create policy unit_registrations_update on public.unit_registrations
  for update using (public.is_owner() or registered_by = auth.uid())
  with check (public.is_owner() or registered_by = auth.uid());

create policy unit_registrations_delete on public.unit_registrations
  for delete using (public.is_owner() or registered_by = auth.uid());

-- ── unit_services ──
drop policy if exists unit_services_select on public.unit_services;
drop policy if exists unit_services_insert on public.unit_services;

create policy unit_services_select on public.unit_services
  for select using (public.is_approved());

create policy unit_services_insert on public.unit_services
  for insert with check (public.is_approved());

-- ── warranty_claims ──
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
-- §12  STORAGE BUCKETS AND POLICIES
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists product_images_read   on storage.objects;
drop policy if exists product_images_insert on storage.objects;
drop policy if exists product_images_update on storage.objects;
drop policy if exists product_images_delete on storage.objects;

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

insert into storage.buckets (id, name, public)
values ('dashboard-banners', 'dashboard-banners', true)
on conflict (id) do update set public = true;

drop policy if exists dashboard_banners_storage_read   on storage.objects;
drop policy if exists dashboard_banners_storage_insert on storage.objects;
drop policy if exists dashboard_banners_storage_update on storage.objects;
drop policy if exists dashboard_banners_storage_delete on storage.objects;

create policy dashboard_banners_storage_read on storage.objects
  for select to public
  using (bucket_id = 'dashboard-banners');

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

insert into storage.buckets (id, name, public)
values ('complaint-attachments', 'complaint-attachments', false)
on conflict (id) do update set public = false;

drop policy if exists complaint_attachments_storage_read   on storage.objects;
drop policy if exists complaint_attachments_storage_insert on storage.objects;
drop policy if exists complaint_attachments_storage_delete on storage.objects;

create policy complaint_attachments_storage_read on storage.objects
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

create policy complaint_attachments_storage_insert on storage.objects
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

create policy complaint_attachments_storage_delete on storage.objects
  for delete to authenticated
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


-- =============================================================================
-- §13  OWNER-ONLY RPCs
-- =============================================================================

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
    set status = 'approved', rejection_reason = null
  where id = p_user returning * into v_profile;
  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user using errcode = 'P0002';
  end if;
  perform public.write_audit_log('dealer.reactivated', 'profile', p_user);
  return v_profile;
end; $fn$;

create or replace function public.set_dealer_role(p_user uuid, p_role public.user_role)
returns public.profiles language plpgsql security definer
set search_path = public, pg_temp
as $fn$
declare v_profile public.profiles;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may change dealer roles' using errcode = '42501';
  end if;
  if p_role not in ('wholesaler', 'retailer') then
    raise exception 'A dealer role may only be changed to wholesaler or retailer' using errcode = '22023';
  end if;
  update public.profiles set role = p_role
  where id = p_user returning * into v_profile;
  if v_profile.id is null then
    raise exception 'No profile found for user %', p_user using errcode = 'P0002';
  end if;
  perform public.write_audit_log('dealer.role_changed', 'profile', p_user,
    jsonb_build_object('new_role', p_role));
  return v_profile;
end; $fn$;

drop function if exists public.top_scanned_products(int, int);
create or replace function public.top_scanned_products(p_limit int default 5, p_days int default 30)
returns table (
  product_id uuid, product_name text, product_code text,
  category public.product_category, scan_count bigint
) language plpgsql security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may access scan analytics' using errcode = '42501';
  end if;
  return query
  select p.id, p.name, p.product_code, p.category, count(s.id) as scan_count
  from public.scan_events s
  join public.products p on p.id = s.product_id
  where s.scanned_at >= (now() - (p_days || ' days')::interval)
  group by p.id, p.name, p.product_code, p.category
  order by scan_count desc, p.name asc
  limit p_limit;
end; $fn$;

drop function if exists public.recent_dealer_activity(int);
create or replace function public.recent_dealer_activity(p_limit int default 10)
returns table (
  user_id uuid, full_name text, firm_name text, phone text,
  role public.user_role, status public.account_status,
  last_activity timestamptz, activity_type text
) language plpgsql security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may access dealer analytics' using errcode = '42501';
  end if;
  return query
  with latest as (
    select distinct on (p.id)
      p.id as user_id, p.full_name, p.firm_name, p.phone, p.role, p.status,
      coalesce(s.scanned_at, p.created_at) as last_activity,
      case when s.scanned_at is not null then 'scan' else 'signup' end as activity_type
    from public.profiles p
    left join public.scan_events s on s.scanned_by = p.id
    order by p.id, s.scanned_at desc nulls last
  )
  select * from latest order by last_activity desc limit p_limit;
end; $fn$;

drop function if exists public.dealer_counts();
create or replace function public.dealer_counts()
returns table (wholesaler_count bigint, retailer_count bigint, pending_count bigint)
language plpgsql security definer
set search_path = public, pg_temp
as $fn$
begin
  if not public.is_owner() then
    raise exception 'Only the owner may view dealer counts' using errcode = '42501';
  end if;
  return query
  select
    count(*) filter (where role = 'wholesaler' and status = 'approved') as wholesaler_count,
    count(*) filter (where role = 'retailer'   and status = 'approved') as retailer_count,
    count(*) filter (where status = 'pending')                         as pending_count
  from public.profiles;
end; $fn$;

drop function if exists public.dealer_activity(uuid);
create or replace function public.dealer_activity(p_user uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp
as $fn$
declare
  v_scan_count bigint;
  v_last_scan  timestamptz;
  v_registered timestamptz;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may view dealer activity' using errcode = '42501';
  end if;
  select created_at into v_registered from public.profiles where id = p_user;
  if v_registered is null then
    raise exception 'No profile found for user %', p_user using errcode = 'P0002';
  end if;
  select count(*), max(scanned_at) into v_scan_count, v_last_scan
  from public.scan_events where scanned_by = p_user;
  return jsonb_build_object(
    'registered_at', v_registered,
    'total_scans',   v_scan_count,
    'last_scan_at',  v_last_scan
  );
end; $fn$;

drop function if exists public.dealer_email(uuid);
create or replace function public.dealer_email(p_user uuid)
returns text language plpgsql security definer
set search_path = public, pg_temp
as $fn$
declare v_email text;
begin
  if not public.is_owner() then
    raise exception 'Only the owner may view dealer email addresses' using errcode = '42501';
  end if;
  select email into v_email from auth.users where id = p_user;
  if v_email is null then
    raise exception 'No auth record found for user %', p_user using errcode = 'P0002';
  end if;
  return v_email;
end; $fn$;


-- =============================================================================
-- §14  UNIT / WARRANTY / QR RPCs
-- =============================================================================

-- ── allocate_product_qr_labels ──
drop function if exists public.allocate_product_qr_labels(uuid, int);
create or replace function public.allocate_product_qr_labels(
  p_product_id uuid,
  p_count int
)
returns jsonb
language plpgsql volatile security definer
set search_path = public, pg_temp
as $$
declare
  v_prod record;
  v_start_seq int;
  v_code text;
  v_new_labels jsonb := '[]'::jsonb;
  v_pad_len int := 3;
  v_sep text := '-';
  v_seq int;
begin
  if p_count <= 0 then
    return '[]'::jsonb;
  end if;

  select id, product_code into v_prod
  from public.products
  where id = p_product_id;

  if v_prod.id is null then
    raise exception 'Product not found' using errcode = 'P0002';
  end if;

  select coalesce(max(sequence_number), 0) into v_start_seq
  from public.product_qr_labels
  where product_id = p_product_id;

  for i in 1..p_count loop
    v_seq := v_start_seq + i;
    v_code := v_prod.product_code || v_sep || lpad(v_seq::text, v_pad_len, '0');
    insert into public.product_qr_labels (product_id, qr_code, sequence_number)
    values (p_product_id, v_code, v_seq)
    on conflict (product_id, sequence_number) do nothing;
    v_new_labels := v_new_labels || to_jsonb(v_code);
  end loop;

  return v_new_labels;
end;
$$;

-- ── fetch_product_qr_labels ──
drop function if exists public.fetch_product_qr_labels(uuid);
create or replace function public.fetch_product_qr_labels(p_product_id uuid)
returns jsonb
language plpgsql stable security definer
set search_path = public, pg_temp
as $$
declare
  v_labels jsonb;
begin
  select jsonb_agg(qr_code order by sequence_number asc) into v_labels
  from public.product_qr_labels
  where product_id = p_product_id;

  return coalesce(v_labels, '[]'::jsonb);
end;
$$;

-- ── lookup_product_by_barcode ──
drop function if exists public.lookup_product_by_barcode(text);
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

  -- 1. Check dedicated product_qr_labels table first (Authoritative mapping)
  select p.id, p.name, p.product_code, p.model_number, p.category, p.warranty_months, p.description, p.stock_quantity
  into v_prod
  from public.product_qr_labels q
  join public.products p on p.id = q.product_id
  where upper(q.qr_code) = v_clean_serial
  limit 1;

  -- 2. If not found in product_qr_labels, check products table exact matches
  if v_prod.id is null then
    select p.id, p.name, p.product_code, p.model_number, p.category, p.warranty_months, p.description, p.stock_quantity
    into v_prod
    from public.products p
    where upper(p.product_code) = v_clean_serial
      or upper(p.model_number) = v_clean_serial
      or p.id::text = lower(trim(p_barcode))
    limit 1;
  end if;

  if v_prod.id is not null then
    select r.* into v_reg
    from public.unit_registrations r
    where upper(trim(r.unit_id::text)) = v_clean_serial
    order by r.created_at desc
    limit 1;

    return jsonb_build_object(
      'unit_id',                coalesce(v_clean_serial, v_prod.product_code),
      'serial_number',          coalesce(v_clean_serial, v_prod.product_code),
      'status',                 case when v_reg.id is not null then 'registered' else 'available' end,
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

-- ── record_product_scan_dispatch ──
drop function if exists public.record_product_scan_dispatch(text, text);
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
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Authentication required to perform scan/dispatch'
      using errcode = '42501';
  end if;

  select role into v_user_role
  from public.profiles
  where id = v_user_id;

  if v_user_role is null or not public.is_approved() then
    raise exception 'User is not approved to perform scan/dispatch'
      using errcode = '42501';
  end if;

  v_clean_ident := trim(p_product_identifier);
  if v_clean_ident is null or v_clean_ident = '' then
    raise exception 'Product identifier cannot be empty'
      using errcode = '22023';
  end if;

  if p_source is null or p_source not in ('camera', 'manual') then
    p_source := 'camera';
  end if;

  select p.id, p.product_code, p.name, p.stock_quantity
  into v_product
  from public.product_qr_labels q
  join public.products p on p.id = q.product_id
  where upper(q.qr_code) = upper(v_clean_ident)
  limit 1
  for update of p;

  if v_product.id is null then
    select p.id, p.product_code, p.name, p.stock_quantity
    into v_product
    from public.products p
    where p.id::text = lower(v_clean_ident)
       or upper(p.product_code) = upper(v_clean_ident)
       or upper(p.model_number) = upper(v_clean_ident)
    limit 1
    for update;
  end if;

  if v_product.id is null then
    raise exception 'Product not found for identifier %', p_product_identifier
      using errcode = 'P0002';
  end if;

  if coalesce(v_product.stock_quantity, 0) <= 0 then
    raise exception 'Stock depleted for product % (Current stock: 0)', v_product.name
      using errcode = 'P0001';
  end if;

  v_new_stock := v_product.stock_quantity - 1;

  update public.products
  set stock_quantity = v_new_stock,
      in_stock = (v_new_stock > 0),
      updated_at = now()
  where id = v_product.id;

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

-- ── get_warranty_claim_details ──
drop function if exists public.get_warranty_claim_details(uuid);
create or replace function public.get_warranty_claim_details(p_claim_id uuid)
returns jsonb
language plpgsql stable security definer
set search_path = public, pg_temp
as $$
declare
  v_claim record;
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
     or p.id::text = v_claim.unit_id
     or (length(p.product_code) >= 3 and upper(v_claim.unit_id) like (upper(p.product_code) || '-%'))
     or (p.specifications->'_label_tracker'->>'prefix' is not null 
         and upper(v_claim.unit_id) like (upper(p.specifications->'_label_tracker'->>'prefix') || '%'))
  order by length(p.product_code) desc
  limit 1;

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
-- §15  REALTIME PUBLICATION
-- =============================================================================

do $$
declare
  t text;
  tables text[] := array[
    'profiles', 'products', 'product_images', 'scan_events',
    'business_settings', 'dashboard_banners', 'complaints',
    'complaint_messages', 'complaint_attachments', 'unit_registrations',
    'unit_services', 'warranty_claims'
  ];
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;

  foreach t in array tables loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end
$$;


-- =============================================================================
-- §16  GRANT / REVOKE LOCKDOWN
-- =============================================================================

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

grant execute on function public.auth_role()   to anon, authenticated;
grant execute on function public.auth_status() to anon, authenticated;
grant execute on function public.is_owner()    to anon, authenticated;
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

grant execute on function public.generate_ticket_number()           to authenticated;
grant execute on function public.generate_claim_number()            to authenticated;
grant usage, select on sequence public.complaint_ticket_seq         to authenticated;
grant usage, select on sequence public.warranty_claim_seq           to authenticated;
grant execute on function public.get_warranty_claim_details(uuid)   to authenticated;
grant execute on function public.lookup_product_by_barcode(text)    to authenticated, anon;
grant execute on function public.allocate_product_qr_labels(uuid, int) to authenticated;
grant execute on function public.fetch_product_qr_labels(uuid)      to authenticated;
grant execute on function public.record_product_scan_dispatch(text, text) to authenticated;

-- Table and view grants (RLS policies govern row-level access)
grant select, insert, update, delete on public.products         to authenticated, anon;
grant select, insert, update, delete on public.product_images  to authenticated, anon;
grant select, insert, update, delete on public.product_qr_labels to authenticated;
grant select                         on public.catalog_view     to authenticated, anon;
grant select                         on public.catalog_images_view to authenticated, anon;
grant select, update                 on public.profiles         to authenticated, anon;

-- Internal functions kept revoked:
revoke all on function public.handle_new_user()                 from public, authenticated;
revoke all on function public.set_product_code()                from public, authenticated;
revoke all on function public.freeze_product_code()             from public, authenticated;
revoke all on function public.touch_business_settings()         from public, authenticated;
revoke all on function public.write_audit_log(text, text, uuid, jsonb) from public, authenticated;
revoke all on function public.generate_product_code(public.product_category) from public, authenticated;
revoke all on sequence public.product_code_seq from public, anon, authenticated;


-- =============================================================================
-- §17  SEED
-- =============================================================================

insert into public.business_settings (id) values (true)
  on conflict (id) do nothing;
