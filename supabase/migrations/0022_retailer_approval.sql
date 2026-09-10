-- Update public.is_approved() so that Retailers do not require manual admin approval
-- to access products and submit complaints, while Wholesalers still require approval.

create or replace function public.is_approved()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and (
        p.status = 'approved'
        or (p.role = 'retailer' and p.status not in ('rejected', 'suspended'))
      )
  );
$$;
