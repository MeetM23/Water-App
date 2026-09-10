-- 0007_product_images.sql
-- Storage paths for product photography. Objects live in the private
-- 'product-images' bucket (0015) and are served to dealers as signed URLs.

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

-- At most one primary image per product, enforced by the database rather than
-- by the client remembering to clear the previous flag.
create unique index if not exists product_images_one_primary_idx
  on public.product_images (product_id)
  where is_primary;

grant select, insert, update, delete on public.product_images to authenticated;
revoke all on public.product_images from anon;
