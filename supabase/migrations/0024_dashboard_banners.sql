-- 0024_dashboard_banners.sql
-- Table and storage policies for home dashboard banner carousel.

-- 1. Create table for dashboard banners
create table if not exists public.dashboard_banners (
  id uuid primary key default gen_random_uuid(),
  storage_path text not null,
  title text,
  link_url text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.dashboard_banners enable row level security;

-- Drop existing policies if any
drop policy if exists dashboard_banners_select on public.dashboard_banners;
drop policy if exists dashboard_banners_insert on public.dashboard_banners;
drop policy if exists dashboard_banners_update on public.dashboard_banners;
drop policy if exists dashboard_banners_delete on public.dashboard_banners;

-- Authenticated approved users can select active banners; owners can select all banners
create policy dashboard_banners_select on public.dashboard_banners
  for select to authenticated
  using (
    (is_active = true and public.is_approved()) or public.is_owner()
  );

-- Only owners can insert banners
create policy dashboard_banners_insert on public.dashboard_banners
  for insert to authenticated
  with check (public.is_owner());

-- Only owners can update banners
create policy dashboard_banners_update on public.dashboard_banners
  for update to authenticated
  using (public.is_owner())
  with check (public.is_owner());

-- Only owners can delete banners
create policy dashboard_banners_delete on public.dashboard_banners
  for delete to authenticated
  using (public.is_owner());

-- Grants
grant select, insert, update, delete on public.dashboard_banners to authenticated;

-- 2. Storage bucket for dashboard banners
insert into storage.buckets (id, name, public)
values ('dashboard-banners', 'dashboard-banners', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists dashboard_banners_storage_read   on storage.objects;
drop policy if exists dashboard_banners_storage_insert on storage.objects;
drop policy if exists dashboard_banners_storage_update on storage.objects;
drop policy if exists dashboard_banners_storage_delete on storage.objects;

create policy dashboard_banners_storage_read on storage.objects
  for select to authenticated
  using (bucket_id = 'dashboard-banners' and public.is_approved());

create policy dashboard_banners_storage_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'dashboard-banners' and public.is_owner());

create policy dashboard_banners_storage_update on storage.objects
  for update to authenticated
  using (bucket_id = 'dashboard-banners' and public.is_owner())
  with check (bucket_id = 'dashboard-banners' and public.is_owner());

create policy dashboard_banners_storage_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'dashboard-banners' and public.is_owner());
