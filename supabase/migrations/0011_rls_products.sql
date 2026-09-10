-- 0011_rls_products.sql
-- The core of the price-isolation requirement.
--
-- products carries wholesale_price and retail_price side by side, so the only
-- role permitted to read a row is the owner. A wholesaler or retailer issuing
-- `select * from products` is not denied — they simply match no rows, which is
-- the intended behaviour: there is no filtering step in Dart that could be
-- bypassed, because the rows never leave the database.
--
-- Note that FORCE ROW LEVEL SECURITY is deliberately NOT set. The table owner
-- must continue to bypass these policies, because catalog_view (0013) runs as
-- the view owner and is how dealers reach the catalogue at all.

alter table public.products       enable row level security;
alter table public.product_images enable row level security;

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
