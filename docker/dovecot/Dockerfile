FROM ubuntu:22.04

# Install packages
RUN apt-get update && apt-get install -y \
    dovecot-imapd \
    dovecot-pop3d \
    dovecot-pgsql \
    dovecot-managesieved \
    dovecot-sieve \
    supervisor \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/mail
RUN mkdir -p /etc/dovecot/conf.d

# Copy configuration files
COPY config/ /etc/dovecot/conf.d/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh
RUN chmod 640 /etc/dovecot/conf.d/dovecot-sql.conf.ext

# Create mail user
RUN groupadd -g 1000 vmail
RUN useradd -g vmail -u 1000 vmail -d /var/mail
RUN chown -R vmail:vmail /var/mail

# Expose ports
EXPOSE 110 143 993 995 4190

# Use supervisor as the main process
CMD ["/entrypoint.sh"]
