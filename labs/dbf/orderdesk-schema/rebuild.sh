#!/usr/bin/env bash
# Drop, create and load the OrderDesk order database from nothing.
# Usage: ./rebuild.sh [database-name]   (default: orderdesk)
set -euo pipefail
cd "$(dirname "$0")"
DB="${1:-orderdesk}"
dropdb --if-exists "$DB"
createdb "$DB"
psql -v ON_ERROR_STOP=1 -q "$DB" -f schema.sql
psql -v ON_ERROR_STOP=1 -q "$DB" -f seed.sql
echo "rebuilt $DB"
