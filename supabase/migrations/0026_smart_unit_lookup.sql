-- 0026_smart_unit_lookup.sql
-- Enables smart lookup for unit registration and warranty claims.
-- Allows looking up by EITHER:
-- 1. Unit Serial Number (e.g. MWS-SN-DOM-001001-9)
-- 2. Product Code from Catalogue (e.g. MWS-DOM-001006-3)
-- If a product code from the catalogue is queried and no unit record exists yet,
-- a physical unit entry is seamlessly created for registration.

create or replace function public.lookup_unit_by_serial(p_serial text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_unit record;
  v_reg record;
  v_prod record;
  v_res jsonb;
  v_clean_serial text;
begin
  v_clean_serial := upper(trim(p_serial));

  if v_clean_serial is null or v_clean_serial = '' then
    return null;
  end if;

  -- 1. Try finding in product_units by serial_number
  select u.* into v_unit
  from public.product_units u
  where upper(u.serial_number) = v_clean_serial;

  -- 2. If not found in product_units, check if it matches a product's product_code or ID in products
  if v_unit.id is null then
    select p.id, p.name, p.model_number, p.category, p.warranty_months, p.description
    into v_prod
    from public.products p
    where upper(p.product_code) = v_clean_serial
       or p.id::text = lower(trim(p_serial));

    if v_prod.id is not null then
      -- Auto-create a physical unit record for this product code so registration/claim works seamlessly
      insert into public.product_units (product_id, serial_number, created_by)
      values (v_prod.id, v_clean_serial, auth.uid())
      on conflict (serial_number) do update set serial_number = excluded.serial_number
      returning * into v_unit;
    end if;
  end if;

  -- 3. If still not found, return null
  if v_unit.id is null then
    return null;
  end if;

  -- Fetch associated product info if not fetched above
  if v_prod.id is null then
    select p.id, p.name, p.model_number, p.category, p.warranty_months, p.description
    into v_prod
    from public.products p
    where p.id = v_unit.product_id;
  end if;

  -- Fetch registration info if registered
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
    'default_warranty_months', coalesce(v_prod.warranty_months, 12),
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

grant execute on function public.lookup_unit_by_serial(text) to authenticated, anon;
