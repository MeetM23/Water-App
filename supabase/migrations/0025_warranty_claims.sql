-- 0025_warranty_claims.sql
-- Warranty Claims database schema, ticket sequence, table, status workflow, and RLS policies.

create sequence if not exists public.warranty_claim_seq start 1001;

create or replace function public.generate_claim_number()
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  v_seq bigint;
begin
  v_seq := nextval('public.warranty_claim_seq');
  return 'CLM-' || lpad(v_seq::text, 6, '0');
end;
$$;

-- Create warranty_claims table
create table if not exists public.warranty_claims (
  id             uuid primary key default gen_random_uuid(),
  claim_number   text not null unique default public.generate_claim_number(),
  unit_id        uuid not null references public.product_units(id) on delete cascade,
  user_id        uuid not null references public.profiles(id) on delete cascade,
  claim_type     text not null,
  description    text not null,
  contact_phone  text not null,
  status         text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'resolved')),
  admin_notes    text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index if not exists idx_warranty_claims_unit_id on public.warranty_claims(unit_id);
create index if not exists idx_warranty_claims_user_id on public.warranty_claims(user_id);
create index if not exists idx_warranty_claims_status on public.warranty_claims(status);

-- RPC to look up all details of a warranty claim for Admin or User
create or replace function public.get_warranty_claim_details(p_claim_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_claim record;
  v_unit record;
  v_prod record;
  v_user record;
  v_reg record;
  v_res jsonb;
begin
  select c.* into v_claim
  from public.warranty_claims c
  where c.id = p_claim_id;

  if not found then
    return null;
  end if;

  select u.* into v_unit
  from public.product_units u
  where u.id = v_claim.unit_id;

  select p.id, p.name, p.model_number, p.category, p.description
  into v_prod
  from public.products p
  where p.id = v_unit.product_id;

  select pr.full_name, pr.mobile_number, pr.company_name, pr.role
  into v_user
  from public.profiles pr
  where pr.id = v_claim.user_id;

  select r.* into v_reg
  from public.unit_registrations r
  where r.unit_id = v_unit.id;

  v_res := jsonb_build_object(
    'id', v_claim.id,
    'claim_number', v_claim.claim_number,
    'claim_type', v_claim.claim_type,
    'description', v_claim.description,
    'contact_phone', v_claim.contact_phone,
    'status', v_claim.status,
    'admin_notes', v_claim.admin_notes,
    'created_at', v_claim.created_at,
    'updated_at', v_claim.updated_at,
    'user_id', v_claim.user_id,
    'user_full_name', v_user.full_name,
    'user_company', v_user.company_name,
    'user_phone', v_user.mobile_number,
    'user_role', v_user.role,
    'unit_id', v_unit.id,
    'serial_number', v_unit.serial_number,
    'product_id', v_prod.id,
    'product_name', v_prod.name,
    'model_number', v_prod.model_number,
    'category', v_prod.category,
    'registration', case when v_reg.id is not null then jsonb_build_object(
      'id', v_reg.id,
      'customer_name', v_reg.customer_name,
      'customer_phone', v_reg.customer_phone,
      'installation_date', v_reg.installation_date,
      'warranty_months', v_reg.warranty_months
    ) else null end
  );

  return v_res;
end;
$$;

-- RLS & Security
alter table public.warranty_claims enable row level security;

-- Select: Owner can read all claims; Dealers can read only their own claims
drop policy if exists warranty_claims_select on public.warranty_claims;
create policy warranty_claims_select on public.warranty_claims
  for select to authenticated
  using (public.is_owner() or (public.is_approved() and user_id = auth.uid()));

-- Insert: Approved dealers can submit claims for themselves
drop policy if exists warranty_claims_insert on public.warranty_claims;
create policy warranty_claims_insert on public.warranty_claims
  for insert to authenticated
  with check (public.is_approved() and user_id = auth.uid());

-- Update: Only Owner can update claim status and admin notes
drop policy if exists warranty_claims_update on public.warranty_claims;
create policy warranty_claims_update on public.warranty_claims
  for update to authenticated
  using (public.is_owner());

-- Grants
grant select, insert, update on public.warranty_claims to authenticated;
grant usage, select on sequence public.warranty_claim_seq to authenticated;
grant execute on function public.generate_claim_number() to authenticated;
grant execute on function public.get_warranty_claim_details(uuid) to authenticated;
