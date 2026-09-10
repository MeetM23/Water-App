-- 0015_storage.sql
-- Private bucket for product photography.
--
-- The bucket is private, so an object URL alone grants nothing: the app hands
-- dealers time-limited signed URLs generated after the read policy below has
-- already been satisfied. A public bucket would let anyone holding the project
-- URL enumerate the client catalogue imagery.

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists product_images_read   on storage.objects;
drop policy if exists product_images_insert on storage.objects;
drop policy if exists product_images_update on storage.objects;
drop policy if exists product_images_delete on storage.objects;

create policy product_images_read on storage.objects
  for select to authenticated
  using (bucket_id = 'product-images' and public.is_approved());

create policy product_images_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'product-images' and public.is_owner());

create policy product_images_update on storage.objects
  for update to authenticated
  using (bucket_id = 'product-images' and public.is_owner())
  with check (bucket_id = 'product-images' and public.is_owner());

create policy product_images_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'product-images' and public.is_owner());
