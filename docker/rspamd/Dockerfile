FROM ubuntu:22.04

# Install packages
RUN apt-get update && apt-get install -y \
    rspamd \
    redis-tools \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/rspamd/local.d
RUN mkdir -p /var/lib/rspamd

# Copy configuration files
COPY config/ /etc/rspamd/local.d/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh
RUN chown -R _rspamd:_rspamd /var/lib/rspamd
RUN chown -R _rspamd:_rspamd /etc/rspamd/local.d

# Expose ports
EXPOSE 11334 11332

# Use supervisor as the main process
CMD ["/entrypoint.sh"]
