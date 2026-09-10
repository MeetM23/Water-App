-- 0013_catalog_views.sql
-- The only path by which a wholesaler or retailer reads the catalogue.
--
-- WHY THIS IS SAFE
--
-- security_invoker = false makes the view execute with the privileges of its
-- owner (postgres) rather than the caller. The owner bypasses the products RLS
-- policies from 0011, which is what lets the view read rows that the caller
-- cannot read directly. PostgreSQL has no SECURITY DEFINER keyword for views;
-- a non-invoker view owned by a privileged role is the equivalent construct.
--
-- The entitled price is resolved inside the view as a single output column
-- named `price`. wholesale_price and retail_price are not columns of the view
-- at all, so there is no projection, filter, ORDER BY, aggregate or join a
-- client can write that reaches the other number. This is the guarantee the
-- brief asks for, and it holds regardless of what the Flutter app does.
--
-- security_barrier = true stops a caller-supplied function in a WHERE clause
-- from being evaluated ahead of the is_approved() qual of the view, which
-- would otherwise leak the existence of rows to an unapproved account.

drop view if exists public.catalog_view;
drop view if exists public.catalog_images_view;

create view public.catalog_view
with (security_invoker = false, security_barrier = true)
as
select
  p.id,
  p.product_code,
  p.name,
  p.model_number,
  p.category,
  p.description,
  p.capacity,
  p.specifications,
  p.warranty_months,
  p.in_stock,
  (
    select pi.storage_path
    from public.product_images pi
    where pi.product_id = p.id
    order by pi.is_primary desc, pi.sort_order asc, pi.id asc
    limit 1
  ) as primary_image_path,
  case public.auth_role()
    when 'wholesaler' then p.wholesale_price
    else p.retail_price
  end as price
from public.products p
where p.is_active = true
  and public.is_approved();

comment on view public.catalog_view is
  $c$Dealer-facing catalogue. Exposes exactly one price column, resolved from
the role of the caller. Returns zero rows unless the caller is approved.$c$;

create view public.catalog_images_view
with (security_invoker = false, security_barrier = true)
as
select
  pi.id,
  pi.product_id,
  pi.storage_path,
  pi.sort_order,
  pi.is_primary
from public.product_images pi
join public.products p on p.id = pi.product_id
where p.is_active = true
  and public.is_approved();

comment on view public.catalog_images_view is
  $c$Image list for products visible in catalog_view. Carries no price data.$c$;

grant select on public.catalog_view        to authenticated;
grant select on public.catalog_images_view to authenticated;
revoke all on public.catalog_view        from anon;
revoke all on public.catalog_images_view from anon;
