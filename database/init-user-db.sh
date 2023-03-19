#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER dev;
    ALTER USER dev WITH ENCRYPTED PASSWORD 'password123';
	CREATE DATABASE quizgame WITH OWNER dev;
EOSQL