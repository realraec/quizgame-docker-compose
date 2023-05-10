#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:postgres}" --dbname "${POSTGRES_DB:db}" <<-EOSQL
	CREATE USER ${DB_USERNAME:dev};
    ALTER USER ${DB_USERNAME:dev} WITH ENCRYPTED PASSWORD '${DB_PASSWORD:password123}';
	CREATE DATABASE ${DB_NAME:quizgame} WITH OWNER ${DB_USERNAME:dev};
EOSQL