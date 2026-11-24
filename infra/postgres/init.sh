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

create_db customer "$CUSTOMER_DB_PASSWORD"
create_db scheduler "$SCHEDULER_DB_PASSWORD"
create_db tariff "$TARIFF_DB_PASSWORD"
create_db notification "$NOTIFICATION_DB_PASSWORD"
create_db utility "$UTILITY_DB_PASSWORD"