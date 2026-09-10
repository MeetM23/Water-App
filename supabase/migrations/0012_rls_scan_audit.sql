-- 0012_rls_scan_audit.sql
-- Scan telemetry is write-only for dealers and read-only for the owner.

alter table public.scan_events enable row level security;
alter table public.audit_log   enable row level security;

drop policy if exists scan_events_insert_approved on public.scan_events;
drop policy if exists scan_events_select_owner    on public.scan_events;

-- scanned_by is pinned to the caller so a dealer cannot forge an event
-- attributed to somebody else.
create policy scan_events_insert_approved on public.scan_events
  for insert to authenticated
  with check (public.is_approved() and scanned_by = auth.uid());

create policy scan_events_select_owner on public.scan_events
  for select to authenticated
  using (public.is_owner());

drop policy if exists audit_log_select_owner on public.audit_log;

create policy audit_log_select_owner on public.audit_log
  for select to authenticated
  using (public.is_owner());

-- audit_log has no INSERT policy and no INSERT grant. Rows arrive only via
-- write_audit_log(), which is SECURITY DEFINER and therefore runs as the table
-- owner, bypassing both.
