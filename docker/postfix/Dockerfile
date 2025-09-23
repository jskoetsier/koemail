FROM ubuntu:22.04

# Install packages
RUN apt-get update && apt-get install -y \
    postfix \
    postfix-pgsql \
    supervisor \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*

# Configure postfix to not start automatically
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN echo "postfix postfix/mailname string mail.example.com" | debconf-set-selections

# Create necessary directories
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/spool/postfix/pid

# Copy configuration files
COPY config/ /etc/postfix/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh
RUN chmod 640 /etc/postfix/pgsql-*.cf

# Expose ports
EXPOSE 25 587 465

# Use supervisor as the main process
CMD ["/entrypoint.sh"]