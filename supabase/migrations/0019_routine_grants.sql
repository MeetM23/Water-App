-- 0019_routine_grants.sql
-- Closes a privilege-escalation hole opened by a REVOKE that never took
-- effect.
--
-- WHAT WAS WRONG
--
-- Every migration in this schema pairs its routines with
--
--     revoke execute on function public.<fn>(...) from public;
--     grant  execute on function public.<fn>(...) to authenticated;
--
-- and the first line does nothing. A Supabase project ships with
--
--     alter default privileges in schema public
--       grant all on functions to postgres, anon, authenticated, service_role;
--
-- so every function created in `public` is born with an EXPLICIT execute grant
-- to `anon` and to `authenticated`. `REVOKE ... FROM PUBLIC` removes only the
-- implicit PUBLIC grant; the explicit ones survive untouched. Verified on
-- 30 August 2026: before this migration, has_function_privilege('anon', ...)
-- was true for all twenty-four routines in the schema, promote_owner()
-- included.
--
-- Nineteen of them survived that anyway, because each one re-asserts
-- is_owner() in its own body and is_owner() is false for an anonymous caller.
-- Two did not:
--
--   * public.promote_owner(text) has no body check by design -- it is the
--     documented way to create the FIRST owner, at a moment when no owner
--     exists to authorise it. The trigger that would otherwise stop it,
--     guard_profile_privilege_columns(), deliberately exempts callers with no
--     JWT so that seed.sql can run, and an anonymous PostgREST caller is
--     exactly such a caller. The result was reproducible end to end: sign up
--     through the app, then POST /rest/v1/rpc/promote_owner with nothing but
--     the anon key that ships inside the APK, and the account came back
--     owner/approved -- holding both price columns, the whole dealer network,
--     every dealer's email address and the audit log.
--
--   * public.write_audit_log(...) is SECURITY DEFINER and so writes past the
--     audit_log policies that have no INSERT arm at all. Any signed-in dealer
--     could forge entries into the owner's audit trail and into the activity
--     feed on their dashboard. `actor` is pinned to auth.uid() so they could
--     not impersonate anybody, but action, entity, entity_id and metadata were
--     entirely theirs -- in the one record the owner consults when something
--     has gone wrong.
--
-- The five trigger functions and the sequence had the same wrong grants, with
-- no exploit behind them today; they are corrected here for the same reason.
--
-- WHAT THIS DOES
--
-- 1. Revokes execute from `anon` on every routine in `public`. The app signs in
--    before it does anything at all, so nothing anonymous needs any of them.
-- 2. Revokes execute from `authenticated` on the routines a client must never
--    call directly: the bootstrap routine, the audit writer, the trigger
--    bodies, and the sequence consumer.
-- 3. Gives promote_owner() a body check, so it is defended even if a future
--    migration re-grants it by accident.
--
-- The owner RPCs keep their grant to `authenticated`: the owner reaches them
-- through PostgREST like any other client, and each one guards itself. The four
-- auth helpers keep theirs too -- RLS policy expressions are evaluated as the
-- calling role, so revoking is_approved() from `authenticated` would make every
-- policy in the schema unevaluable.

-- ---------------------------------------------------------------------------
-- 1. Nothing anonymous calls anything.
-- ---------------------------------------------------------------------------
--
-- Both grants have to go, and they are two different grants. PostgreSQL itself
-- creates every function with EXECUTE granted to PUBLIC; Supabase then adds an
-- explicit grant to anon on top. Removing either one alone leaves the other
-- standing, which is the whole reason this migration exists -- so the loop
-- names both.
do $revoke_anon$
declare
  v_signature text;
begin
  for v_signature in
    select p.oid::regprocedure::text
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
  loop
    execute format('revoke all on function %s from public, anon', v_signature);
  end loop;
end
$revoke_anon$;

-- Re-granted immediately afterwards, because revoking from PUBLIC took these
-- with it. RLS policy expressions are evaluated as the calling role, so a
-- dealer without EXECUTE on is_approved() cannot have a single policy in the
-- schema evaluated for them -- every read would fail rather than return no
-- rows.
grant execute on function public.auth_role()   to authenticated;
grant execute on function public.auth_status() to authenticated;
grant execute on function public.is_owner()    to authenticated;
grant execute on function public.is_approved() to authenticated;

grant execute on function public.approve_dealer(uuid, public.user_role)  to authenticated;
grant execute on function public.reject_dealer(uuid, text)               to authenticated;
grant execute on function public.suspend_dealer(uuid)                    to authenticated;
grant execute on function public.reactivate_dealer(uuid)                 to authenticated;
grant execute on function public.set_dealer_role(uuid, public.user_role) to authenticated;
grant execute on function public.top_scanned_products(int, int)          to authenticated;
grant execute on function public.recent_dealer_activity(int)             to authenticated;
grant execute on function public.dealer_counts()                         to authenticated;
grant execute on function public.dealer_activity(uuid)                   to authenticated;
grant execute on function public.dealer_email(uuid)                      to authenticated;

-- Pure, side-effect-free code-format helpers. The client mirrors the check
-- character in Dart and never calls these, but they leak nothing and refusing
-- them would be arbitrary.
grant execute on function public.product_code_check_char(text) to authenticated;
grant execute on function public.validate_product_code(text)   to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Routines a signed-in client must never call directly.
-- ---------------------------------------------------------------------------

-- Trigger bodies. PostgreSQL checks EXECUTE on a trigger function when the
-- trigger is CREATED, not each time it fires, so removing the grant does not
-- stop signup, product creation or a settings edit. Checks v8..v13 in
-- supabase/tests/rls_test.sql assert the grants are gone, and the release
-- checklist in docs/RUNBOOK.md exercises signup, product creation and a
-- settings edit against a real stack afterwards.
revoke all on function public.handle_new_user()                 from public, authenticated;
revoke all on function public.set_product_code()                from public, authenticated;
revoke all on function public.freeze_product_code()             from public, authenticated;
revoke all on function public.touch_business_settings()         from public, authenticated;
revoke all on function public.guard_profile_privilege_columns() from public, authenticated;

-- The audit writer. Its callers are the owner RPCs, which are SECURITY DEFINER
-- and therefore run as the function owner, so they keep reaching it.
revoke all on function
  public.write_audit_log(text, text, uuid, jsonb) from public, authenticated;

-- Sequence numbers are consumed only through set_product_code(), which is
-- SECURITY DEFINER for exactly this reason. 0006 said so and was overruled by
-- the default privileges.
revoke all on function
  public.generate_product_code(public.product_category) from public, authenticated;
revoke all on sequence public.product_code_seq from public, anon, authenticated;

-- promote_owner() lives in seed.sql rather than in a migration, so it may or
-- may not exist on a given database. Guarded rather than assumed.
do $revoke_promote$
begin
  if to_regprocedure('public.promote_owner(text)') is not null then
    execute 'revoke all on function public.promote_owner(text) '
            'from anon, authenticated';
  end if;
end
$revoke_promote$;

-- ---------------------------------------------------------------------------
-- 3. A body check on the bootstrap routine.
-- ---------------------------------------------------------------------------
--
-- Not is_owner(): that would make the routine useless for the one job it has,
-- which is creating the first owner when there is no owner to authorise it.
-- The condition that actually distinguishes the legitimate call from the attack
-- is whether an owner already exists. Before one does, anybody running this
-- from the SQL editor is bootstrapping. After one does, only that owner may
-- promote anybody else.
do $guard_promote$
begin
  if to_regprocedure('public.promote_owner(text)') is null then
    return;
  end if;

  execute $fn$
    create or replace function public.promote_owner(p_email text)
    returns void
    language plpgsql
    security definer
    set search_path = public, auth, pg_temp
    as $body$
    declare
      v_user_id uuid;
    begin
      if exists (
           select 1 from public.profiles
            where role = 'owner' and status = 'approved'
         ) and not public.is_owner() then
        raise exception
          'An owner already exists; only the owner may promote another account'
          using errcode = '42501';
      end if;

      select id into v_user_id from auth.users
       where lower(email) = lower(p_email);

      if v_user_id is null then
        raise exception 'No account exists for %', p_email using errcode = 'P0002';
      end if;

      update public.profiles
         set role        = 'owner',
             status      = 'approved',
             approved_at = now()
       where id = v_user_id;
    end;
    $body$;
  $fn$;

  execute 'revoke all on function public.promote_owner(text) '
          'from public, anon, authenticated';
end
$guard_promote$;

comment on function public.write_audit_log(text, text, uuid, jsonb) is
  $c$Owner-RPC internal. Not callable by a client: see 0019_routine_grants.sql.$c$;
