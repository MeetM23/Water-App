-- 0020_guest_catalog_views.sql
-- Enables guest catalogue and image browsing for unauthenticated (anon) users.
-- Active products are visible to guests (auth.uid() IS NULL) and approved dealers (is_approved()).
-- Pending/suspended accounts continue receiving 0 rows. Owner policies remain untouched.

-- 1. Update catalog_view for guest access
create or replace view public.catalog_view
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
  $c$Public & Dealer catalogue. Exposes single price column. Returns active products for guests or approved dealers; returns zero rows for unapproved authenticated users.$c$;

-- 2. Update catalog_images_view for guest access
create or replace view public.catalog_images_view
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

-- 3. Grants for views and helper functions
grant select on public.catalog_view        to anon, authenticated;
grant select on public.catalog_images_view to anon, authenticated;
grant execute on function public.auth_role()   to anon, authenticated;
grant execute on function public.is_approved() to anon, authenticated;

-- 4. Update storage read policy for product images
drop policy if exists product_images_read on storage.objects;

create policy product_images_read on storage.objects
  for select to public
  using (bucket_id = 'product-images' and (auth.uid() is null or public.is_approved()));

