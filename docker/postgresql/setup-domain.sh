#!/bin/bash
set -e

# Replace domain placeholder in the SQL initialization files
if [ -n "$DOMAIN" ]; then
    echo "Setting up database with domain: $DOMAIN"
    
    # Replace placeholders in the SQL files
    sed -i "s/__DOMAIN__/$DOMAIN/g" /docker-entrypoint-initdb.d/02-default-data.sql
    
    echo "Database initialization files configured for domain: $DOMAIN"
fi