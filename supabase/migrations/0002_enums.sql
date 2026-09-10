-- 0002_enums.sql
-- Domain enumerations. These are referenced by tables, helper functions and
-- RPCs, so they must be created before anything else in the public schema.

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('owner', 'wholesaler', 'retailer');
  end if;

  if not exists (select 1 from pg_type where typname = 'account_status') then
    create type public.account_status as enum
      ('pending', 'approved', 'rejected', 'suspended');
  end if;

  if not exists (select 1 from pg_type where typname = 'product_category') then
    create type public.product_category as enum
      ('domestic', 'commercial', 'industrial', 'spare_part', 'accessory');
  end if;
end
$$;
