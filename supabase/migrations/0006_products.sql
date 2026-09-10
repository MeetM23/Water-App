-- 0006_products.sql
-- The catalogue. This table holds BOTH prices and is therefore the single
-- most sensitive object in the schema: no dealer ever reads it directly.
-- Dealer access is served exclusively by catalog_view (0013).

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

comment on table public.products is
  'Catalogue master. Contains both price columns; readable only by the owner.';

create index if not exists products_category_idx on public.products (category);
create index if not exists products_active_idx   on public.products (is_active);

-- Assigns the permanent product code. Any value supplied by the client is
-- discarded, so the code cannot be chosen or spoofed from the app.
--
-- SECURITY DEFINER because product_code_seq is deliberately not granted to
-- `authenticated`: sequence numbers are only ever consumed through this
-- trigger, never by a direct call to generate_product_code().
create or replace function public.set_product_code()
returns trigger
language plpgsql
security definer
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

-- The code is printed onto physical labels, so it must never change once
-- issued. Rejecting the change is preferable to silently ignoring it.
create or replace function public.freeze_product_code()
returns trigger
language plpgsql
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

grant select, insert, update, delete on public.products to authenticated;
revoke all on public.products from anon;
