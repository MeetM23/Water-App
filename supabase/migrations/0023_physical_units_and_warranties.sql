-- 0023_physical_units_and_warranties.sql
-- Physical RO unit tracking, warranty activation, and service history.

create sequence if not exists public.product_unit_seq start 1001;

-- 1. Physical product units (individual manufactured RO machines)
create table if not exists public.product_units (
  id              uuid primary key default gen_random_uuid(),
  product_id      uuid not null references public.products (id) on delete restrict,
  serial_number   text not null unique,
  manufactured_at timestamptz not null default now(),
  created_by      uuid references auth.users (id),
  created_at      timestamptz not null default now()
);

create index if not exists product_units_product_idx on public.product_units (product_id);
create index if not exists product_units_serial_idx  on public.product_units (serial_number);

-- 2. Unit warranty registrations
create table if not exists public.unit_registrations (
  id                  uuid primary key default gen_random_uuid(),
  unit_id             uuid not null unique references public.product_units (id) on delete cascade,
  registered_by       uuid references auth.users (id),
  registered_role     public.user_role,
  customer_name       text not null,
  customer_phone      text not null,
  customer_city       text,
  customer_address    text,
  purchase_date       date not null,
  installation_date   date not null,
  warranty_start_date date not null,
  warranty_months     int not null check (warranty_months >= 0),
  invoice_number      text,
  invoice_url         text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists unit_registrations_unit_idx on public.unit_registrations (unit_id);
create index if not exists unit_registrations_phone_idx on public.unit_registrations (customer_phone);

-- 3. Service history records
create table if not exists public.unit_services (
  id           uuid primary key default gen_random_uuid(),
  unit_id      uuid not null references public.product_units (id) on delete cascade,
  complaint_id uuid references public.complaints (id) on delete set null,
  serviced_by  uuid references auth.users (id),
  service_type text not null,
  notes        text,
  serviced_at  timestamptz not null default now()
);

create index if not exists unit_services_unit_idx on public.unit_services (unit_id);

-- 4. Add optional unit_id to complaints
alter table public.complaints
  add column if not exists unit_id uuid references public.product_units (id) on delete set null;

-- Function to generate unit serials
create or replace function public.generate_unit_serial(
  p_category public.product_category
)
returns text
language plpgsql
volatile
set search_path = public, pg_temp
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
    raise exception 'Unmapped product category: %', p_category
      using errcode = '22023';
  end if;

  v_digits := lpad(nextval('public.product_unit_seq')::text, 6, '0');

  return 'MWS-SN-' || v_prefix || '-' || v_digits || '-'
         || public.product_code_check_char(v_digits);
end;
$$;

-- Batch RPC for Owner to create N unit records and return their serial numbers
create or replace function public.batch_generate_product_units(
  p_product_id uuid,
  p_quantity int
)
returns table (
  unit_id uuid,
  serial_number text
)
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_category public.product_category;
  v_serial text;
  v_i int;
begin
  if p_quantity <= 0 or p_quantity > 500 then
    raise exception 'Quantity must be between 1 and 500' using errcode = '22023';
  end if;

  select p.category into v_category
  from public.products p
  where p.id = p_product_id;

  if not found then
    raise exception 'Product not found: %', p_product_id using errcode = '22023';
  end if;

  for v_i in 1 .. p_quantity loop
    v_serial := public.generate_unit_serial(v_category);
    insert into public.product_units (product_id, serial_number, created_by)
    values (p_product_id, v_serial, auth.uid())
    returning public.product_units.id, public.product_units.serial_number
    into unit_id, serial_number;

    return next;
  end loop;
end;
$$;

-- 5. RPC to look up unit & warranty by serial number
create or replace function public.lookup_unit_by_serial(p_serial text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_unit record;
  v_reg record;
  v_prod record;
  v_res jsonb;
begin
  select u.* into v_unit
  from public.product_units u
  where upper(u.serial_number) = upper(trim(p_serial));

  if not found then
    return null;
  end if;

  select p.id, p.name, p.model_number, p.category, p.warranty_months, p.description
  into v_prod
  from public.products p
  where p.id = v_unit.product_id;

  select r.* into v_reg
  from public.unit_registrations r
  where r.unit_id = v_unit.id;

  v_res := jsonb_build_object(
    'unit_id', v_unit.id,
    'serial_number', v_unit.serial_number,
    'manufactured_at', v_unit.manufactured_at,
    'product_id', v_prod.id,
    'product_name', v_prod.name,
    'model_number', v_prod.model_number,
    'category', v_prod.category,
    'description', v_prod.description,
    'default_warranty_months', v_prod.warranty_months,
    'registration', case when v_reg.id is not null then jsonb_build_object(
      'id', v_reg.id,
      'registered_by', v_reg.registered_by,
      'customer_name', v_reg.customer_name,
      'customer_phone', v_reg.customer_phone,
      'customer_city', v_reg.customer_city,
      'customer_address', v_reg.customer_address,
      'purchase_date', v_reg.purchase_date,
      'installation_date', v_reg.installation_date,
      'warranty_start_date', v_reg.warranty_start_date,
      'warranty_months', v_reg.warranty_months,
      'warranty_end_date', (v_reg.warranty_start_date + (v_reg.warranty_months || ' months')::interval)::date,
      'invoice_number', v_reg.invoice_number,
      'created_at', v_reg.created_at
    ) else null end
  );

  return v_res;
end;
$$;

-- RLS & Grants
alter table public.product_units enable row level security;
alter table public.unit_registrations enable row level security;
alter table public.unit_services enable row level security;

-- Policies for product_units
create policy product_units_select on public.product_units
  for select using (public.is_approved() or auth.uid() is null);

create policy product_units_owner on public.product_units
  for all using (public.is_owner());

-- Policies for unit_registrations
create policy unit_registrations_select on public.unit_registrations
  for select using (
    public.is_owner() or
    registered_by = auth.uid() or
    public.is_approved()
  );

create policy unit_registrations_insert on public.unit_registrations
  for insert with check (public.is_approved());

-- Policies for unit_services
create policy unit_services_select on public.unit_services
  for select using (public.is_approved());

create policy unit_services_insert on public.unit_services
  for insert with check (public.is_approved());

grant select, insert, update, delete on public.product_units to authenticated;
grant select, insert, update, delete on public.unit_registrations to authenticated;
grant select, insert, update, delete on public.unit_services to authenticated;
grant execute on function public.lookup_unit_by_serial(text) to authenticated, anon;
grant execute on function public.batch_generate_product_units(uuid, int) to authenticated;
