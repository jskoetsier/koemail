#!/bin/bash
set -e

# Copy the SQL files to a writable location and process them
echo "Processing PostgreSQL initialization files..."

if [ -n "$DOMAIN" ]; then
    echo "Setting up database with domain: $DOMAIN"

    # Copy SQL files to writable directory
    cp /docker-entrypoint-initdb.d/01-schema.sql /tmp/01-schema.sql
    cp /docker-entrypoint-initdb.d/02-default-data.sql /tmp/02-default-data.sql

    # Replace domain placeholders
    sed -i "s/__DOMAIN__/$DOMAIN/g" /tmp/02-default-data.sql

    # Move processed files back
    mv /tmp/01-schema.sql /docker-entrypoint-initdb.d/01-schema.sql
    mv /tmp/02-default-data.sql /docker-entrypoint-initdb.d/02-default-data.sql

    echo "Database initialization files configured for domain: $DOMAIN"
fi

# Call original PostgreSQL entrypoint
exec docker-entrypoint.sh "$@"
