-- =============================================================================
-- MARUTI WATER SOLUTION — PERMISSIONS & GRANTS RESTORATION
-- =============================================================================
-- Run this script in Supabase SQL Editor if you only want to restore
-- permissions without re-running the entire master_schema.sql file.

-- 1. Grant table and view access (RLS policies govern actual row filtering)
grant select, insert, update, delete on public.products           to authenticated, anon;
grant select, insert, update, delete on public.product_images    to authenticated, anon;
grant select, insert, update, delete on public.product_qr_labels  to authenticated;
grant select                         on public.catalog_view       to authenticated, anon;
grant select                         on public.catalog_images_view to authenticated, anon;
grant select, update                 on public.profiles           to authenticated, anon;

-- 2. Grant execution on auth and dashboard helper functions
grant execute on function public.is_owner()    to anon, authenticated;
grant execute on function public.is_approved() to anon, authenticated;
grant execute on function public.auth_role()   to anon, authenticated;
grant execute on function public.auth_status() to anon, authenticated;
grant execute on function public.top_scanned_products(int, int) to authenticated, anon;
grant execute on function public.recent_dealer_activity(int)    to authenticated, anon;
grant execute on function public.dealer_counts()                to authenticated, anon;
grant execute on function public.dealer_activity(uuid)          to authenticated, anon;

-- 3. Refresh catalog views to guarantee clean column layout
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
