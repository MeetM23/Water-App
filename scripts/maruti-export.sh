#!/usr/bin/env bash
#
# maruti-export.sh — daily logical export of the two irreplaceable tables.
#
# Supabase's own backups are a full-cluster restore: all or nothing, and only
# back to a whole snapshot. `products` (both price lists, every printed code)
# and `profiles` (the dealer network) are small enough to export separately and
# restore selectively, which is the difference between fixing one mistake and
# undoing a day.
#
#   export DATABASE_URL='postgresql://…'
#   ./scripts/maruti-export.sh ~/maruti-backups
#
# Requires psql and pg_dump on PATH. See docs/BACKUP.md for the schedule, where
# the files should end up, and the restore drill.

set -euo pipefail

: "${DATABASE_URL:?set DATABASE_URL to the project connection string}"

DEST="${1:-$HOME/maruti-backups}"
STAMP="$(date +%Y-%m-%d)"
RETAIN_DAYS=90

mkdir -p "$DEST"

echo "Exporting to $DEST …"

# Ordered by product_code rather than by id, so a diff between two days shows
# what actually changed instead of a reshuffle.
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -c "\copy (select * from public.products order by product_code) \
      to '$DEST/products-$STAMP.csv' with (format csv, header)"

# approved_by and rejection_reason are deliberately left out: the first is a
# uuid that means nothing outside the database, and the second can carry a
# candid remark about a business the client still deals with.
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -c "\copy (select id, role, status, full_name, firm_name, phone, city, \
             state, gst_number, approved_at, created_at \
             from public.profiles order by created_at) \
      to '$DEST/profiles-$STAMP.csv' with (format csv, header)"

# The schema too. Small, and the thing you actually need to rebuild from
# nothing if the repository is ever lost as well.
pg_dump "$DATABASE_URL" --schema-only --no-owner --no-privileges \
  > "$DEST/schema-$STAMP.sql"

find "$DEST" -name 'products-*.csv' -mtime "+$RETAIN_DAYS" -delete
find "$DEST" -name 'profiles-*.csv' -mtime "+$RETAIN_DAYS" -delete
find "$DEST" -name 'schema-*.sql'   -mtime "+$RETAIN_DAYS" -delete

echo "Done:"
ls -la "$DEST" | grep "$STAMP"

# A backup on the same disk as the database is not a backup, and a backup on
# the developer's laptop is a backup that leaves when the developer does. Copy
# $DEST somewhere the client controls — see docs/BACKUP.md.
