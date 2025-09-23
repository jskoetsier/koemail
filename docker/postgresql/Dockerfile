FROM postgres:15-alpine

# Copy custom entrypoint script
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh

# Copy initialization files
COPY init/ /docker-entrypoint-initdb.d/

# Make entrypoint executable
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["postgres"]