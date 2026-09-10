-- 0008_scan_events.sql
-- Every barcode lookup, recorded for the owner. Dealers may write their own
-- events but may not read the table back, so one dealer cannot infer another
-- dealer's activity.

create table if not exists public.scan_events (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid references public.products (id) on delete set null,
  scanned_by   uuid references auth.users (id) on delete set null,
  scanned_role public.user_role,
  scanned_at   timestamptz not null default now(),
  source       text not null check (source in ('camera', 'manual'))
);

create index if not exists scan_events_scanned_at_idx
  on public.scan_events (scanned_at desc);
create index if not exists scan_events_product_idx
  on public.scan_events (product_id);

grant select, insert on public.scan_events to authenticated;
revoke all on public.scan_events from anon;
