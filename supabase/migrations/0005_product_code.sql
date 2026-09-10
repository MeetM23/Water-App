-- 0005_product_code.sql
-- Permanent, human-readable product codes.
--
-- Format:  MWS-<PREFIX>-<NNNNNN>-<C>
--   PREFIX  three letters derived from the product category
--   NNNNNN  the next value of product_code_seq, left-padded to six digits
--   C       a single base36 check character
--
-- Check character algorithm. This definition is authoritative; the Dart
-- client mirrors it when manual code entry ships, so that a code typed by
-- hand can be validated without a round trip.
--   sum = SUM over i of ( digit_i * i ), i counted 1..n from the left
--   C   = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'[ sum % 36 ]
--
-- Worked example: sequence 1042 -> digits 0,0,1,0,4,2
--   0*1 + 0*2 + 1*3 + 0*4 + 4*5 + 2*6 = 35  ->  'Z'
--   full code: MWS-DOM-001042-Z

create sequence if not exists public.product_code_seq start 1001;

create or replace function public.product_code_check_char(p_digits text)
returns text
language plpgsql
immutable
as $$
declare
  v_alphabet constant text := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  v_sum      int := 0;
  v_index    int;
begin
  for v_index in 1 .. length(p_digits) loop
    v_sum := v_sum + (substr(p_digits, v_index, 1))::int * v_index;
  end loop;

  return substr(v_alphabet, (v_sum % 36) + 1, 1);
end;
$$;

create or replace function public.generate_product_code(
  p_category public.product_category
)
returns text
language plpgsql
volatile
as $$
declare
  v_prefix text;
  v_digits text;
begin
  v_prefix := case p_category
                when 'domestic'   then 'DOM'
                when 'commercial' then 'COM'
                when 'industrial' then 'IND'
                when 'spare_part' then 'SPR'
                when 'accessory'  then 'ACC'
              end;

  if v_prefix is null then
    raise exception 'Unmapped product category: %', p_category
      using errcode = '22023';
  end if;

  v_digits := lpad(nextval('public.product_code_seq')::text, 6, '0');

  return 'MWS-' || v_prefix || '-' || v_digits || '-'
         || public.product_code_check_char(v_digits);
end;
$$;

-- Validates a code that a user typed by hand instead of scanning it.
-- Returns false rather than raising, so it is safe to call on arbitrary input.
create or replace function public.validate_product_code(p_code text)
returns boolean
language plpgsql
immutable
as $$
declare
  v_parts text[];
begin
  if p_code !~ '^MWS-(DOM|COM|IND|SPR|ACC)-[0-9]{6}-[0-9A-Z]$' then
    return false;
  end if;

  v_parts := string_to_array(p_code, '-');
  return v_parts[4] = public.product_code_check_char(v_parts[3]);
end;
$$;

revoke execute on function public.generate_product_code(public.product_category)
  from public;

grant execute on function public.validate_product_code(text) to authenticated;
grant execute on function public.product_code_check_char(text) to authenticated;
