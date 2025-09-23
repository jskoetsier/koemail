FROM php:8.1-apache

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    unzip \
    wget \
    netcat-openbsd \
    gettext-base \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        zip \
        pdo \
        pdo_mysql \
        curl \
        opcache \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers

# Download and install RainLoop
WORKDIR /var/www/html
RUN wget -q https://www.rainloop.net/repository/webmail/rainloop-latest.zip \
    && unzip rainloop-latest.zip \
    && rm rainloop-latest.zip \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Create data directory
RUN mkdir -p /var/www/html/data \
    && chown -R www-data:www-data /var/www/html/data \
    && chmod -R 755 /var/www/html/data

# Copy configuration files
COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY entrypoint.sh /entrypoint.sh
COPY application.ini /var/www/html/data/_data_/_default_/configs/application.ini

# Set permissions
RUN chmod +x /entrypoint.sh
RUN chown -R www-data:www-data /var/www/html

# Expose port
EXPOSE 80

# Start Apache
CMD ["/entrypoint.sh"]
