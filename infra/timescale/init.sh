#!/bin/bash
set -e

create_db() {
  local name="$1"
  local password="$2"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<EOSQL
CREATE USER ${name} WITH PASSWORD '${password}';
CREATE DATABASE ${name} OWNER ${name};
EOSQL
}

create_db charger "$CHARGER_DB_PASSWORD"
create_db grid "$GRID_DB_PASSWORD"