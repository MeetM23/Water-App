-- 0009_audit_log.sql
-- Append-only record of owner actions. `authenticated` is granted SELECT only
-- (and RLS narrows that to the owner); no INSERT grant exists, so rows can be
-- written only by SECURITY DEFINER routines such as write_audit_log().

create table if not exists public.audit_log (
  id         uuid primary key default gen_random_uuid(),
  actor      uuid references auth.users (id) on delete set null,
  action     text not null,
  entity     text not null,
  entity_id  uuid,
  metadata   jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_log_created_at_idx
  on public.audit_log (created_at desc);
create index if not exists audit_log_entity_idx
  on public.audit_log (entity, entity_id);

create or replace function public.write_audit_log(
  p_action    text,
  p_entity    text,
  p_entity_id uuid,
  p_metadata  jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.audit_log (actor, action, entity, entity_id, metadata)
  values (auth.uid(), p_action, p_entity, p_entity_id,
          coalesce(p_metadata, '{}'::jsonb));
end;
$$;

revoke execute on function
  public.write_audit_log(text, text, uuid, jsonb) from public;

grant select on public.audit_log to authenticated;
revoke all on public.audit_log from anon;
