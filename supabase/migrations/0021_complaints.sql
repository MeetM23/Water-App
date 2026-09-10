-- 0021_complaints.sql
-- Complaint Management module database schema, ticket sequence, tables, storage bucket, and RLS policies.

-- 1. Create domain enums for complaints
do $$
begin
  if not exists (select 1 from pg_type where typname = 'complaint_category') then
    create type public.complaint_category as enum (
      'product_issue',
      'installation_issue',
      'warranty_issue',
      'delivery_issue',
      'billing_issue',
      'technical_issue',
      'other'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'complaint_priority') then
    create type public.complaint_priority as enum (
      'low',
      'medium',
      'high',
      'urgent'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'complaint_status') then
    create type public.complaint_status as enum (
      'open',
      'in_progress',
      'resolved',
      'closed'
    );
  end if;
end
$$;

-- 2. Ticket sequence & generator function
create sequence if not exists public.complaint_ticket_seq start 1001;

create or replace function public.generate_ticket_number()
returns text
language plpgsql
volatile
as $$
declare
  v_seq bigint;
begin
  v_seq := nextval('public.complaint_ticket_seq');
  return 'CMP-' || lpad(v_seq::text, 6, '0');
end;
$$;

-- 3. Create complaints table
create table if not exists public.complaints (
  id uuid primary key default gen_random_uuid(),
  ticket_number text not null unique default public.generate_ticket_number(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  subject text not null,
  category public.complaint_category not null,
  product_id uuid references public.products(id) on delete set null,
  reference_number text,
  description text not null,
  priority public.complaint_priority not null default 'medium'::public.complaint_priority,
  status public.complaint_status not null default 'open'::public.complaint_status,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz
);

-- Index for user lookups and status filtering
create index if not exists idx_complaints_user_id on public.complaints(user_id);
create index if not exists idx_complaints_status on public.complaints(status);
create index if not exists idx_complaints_created_at on public.complaints(created_at desc);

-- 4. Create complaint_messages table (comments/replies & internal admin notes)
create table if not exists public.complaint_messages (
  id uuid primary key default gen_random_uuid(),
  complaint_id uuid not null references public.complaints(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  message text not null,
  is_internal boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_complaint_messages_complaint_id on public.complaint_messages(complaint_id);

-- Trigger to bump complaint.updated_at on new message or status update
create or replace function public.touch_complaint_updated_at()
returns trigger
language plpgsql
as $$
begin
  update public.complaints
     set updated_at = now()
   where id = new.complaint_id;
  return new;
end;
$$;

drop trigger if exists tr_touch_complaint_updated_at on public.complaint_messages;
create trigger tr_touch_complaint_updated_at
  after insert on public.complaint_messages
  for each row execute function public.touch_complaint_updated_at();

-- 5. Create complaint_attachments table
create table if not exists public.complaint_attachments (
  id uuid primary key default gen_random_uuid(),
  complaint_id uuid not null references public.complaints(id) on delete cascade,
  storage_path text not null,
  file_name text not null,
  file_size int,
  created_at timestamptz not null default now()
);

create index if not exists idx_complaint_attachments_complaint_id on public.complaint_attachments(complaint_id);

-- 6. Enable RLS on all tables
alter table public.complaints enable row level security;
alter table public.complaint_messages enable row level security;
alter table public.complaint_attachments enable row level security;

-- RLS Policies for complaints table:
-- Select: Owner can read all; Dealers can read their own
drop policy if exists complaints_select on public.complaints;
create policy complaints_select on public.complaints
  for select to authenticated
  using (public.is_owner() or (public.is_approved() and user_id = auth.uid()));

-- Insert: Approved dealers can create complaints for themselves
drop policy if exists complaints_insert on public.complaints;
create policy complaints_insert on public.complaints
  for insert to authenticated
  with check (public.is_approved() and user_id = auth.uid());

-- Update: Only owner can update complaint status, priority, or details
drop policy if exists complaints_update on public.complaints;
create policy complaints_update on public.complaints
  for update to authenticated
  using (public.is_owner());

-- RLS Policies for complaint_messages table:
-- Select: Owner can read all messages (including internal notes). Approved dealers can read non-internal messages on their complaints.
drop policy if exists complaint_messages_select on public.complaint_messages;
create policy complaint_messages_select on public.complaint_messages
  for select to authenticated
  using (
    public.is_owner()
    or (
      public.is_approved()
      and not is_internal
      and exists (
        select 1 from public.complaints c
        where c.id = complaint_id and c.user_id = auth.uid()
      )
    )
  );

-- Insert: Owner can post messages/notes; Approved dealer can post messages on their own complaint.
drop policy if exists complaint_messages_insert on public.complaint_messages;
create policy complaint_messages_insert on public.complaint_messages
  for insert to authenticated
  with check (
    sender_id = auth.uid()
    and (
      public.is_owner()
      or (
        public.is_approved()
        and not is_internal
        and exists (
          select 1 from public.complaints c
          where c.id = complaint_id and c.user_id = auth.uid()
        )
      )
    )
  );

-- RLS Policies for complaint_attachments table:
drop policy if exists complaint_attachments_select on public.complaint_attachments;
create policy complaint_attachments_select on public.complaint_attachments
  for select to authenticated
  using (
    public.is_owner()
    or (
      public.is_approved()
      and exists (
        select 1 from public.complaints c
        where c.id = complaint_id and c.user_id = auth.uid()
      )
    )
  );

drop policy if exists complaint_attachments_insert on public.complaint_attachments;
create policy complaint_attachments_insert on public.complaint_attachments
  for insert to authenticated
  with check (
    public.is_owner()
    or (
      public.is_approved()
      and exists (
        select 1 from public.complaints c
        where c.id = complaint_id and c.user_id = auth.uid()
      )
    )
  );

-- 7. Private Supabase Storage Bucket for Complaint Attachments
insert into storage.buckets (id, name, public)
values ('complaint-attachments', 'complaint-attachments', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists complaint_attachments_read on storage.objects;
create policy complaint_attachments_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'complaint-attachments'
    and (
      public.is_owner()
      or (
        public.is_approved()
        and exists (
          select 1 from public.complaints c
          where c.id::text = (storage.foldername(name))[1]
            and c.user_id = auth.uid()
        )
      )
    )
  );

drop policy if exists complaint_attachments_write on storage.objects;
create policy complaint_attachments_write on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'complaint-attachments'
    and (
      public.is_owner()
      or (
        public.is_approved()
        and exists (
          select 1 from public.complaints c
          where c.id::text = (storage.foldername(name))[1]
            and c.user_id = auth.uid()
        )
      )
    )
  );

-- 8. Grants for authenticated role
grant select, insert, update on public.complaints to authenticated;
grant select, insert on public.complaint_messages to authenticated;
grant select, insert on public.complaint_attachments to authenticated;
grant usage, select on sequence public.complaint_ticket_seq to authenticated;
grant execute on function public.generate_ticket_number() to authenticated;
