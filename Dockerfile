# Start from the original Drupal image
FROM drupal:10.2.6-php8.2-apache-bookworm
# Set working directory to root of drupal project set in base image
WORKDIR /opt/drupal
# Install drush and any additional Drupal extensions using Composer
# drush https://www.drupal.org/docs/develop/development-tools/drush
RUN composer require 'drush/drush'
# Add volumes for the Drupal installation and files directories
VOLUME ["/var/www/html/modules", "/var/www/html/profiles", "/var/www/html/themes", "/var/www/html/sites"]
# Enable output buffering in PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && echo "output_buffering = On" >> /usr/local/etc/php/php.ini
# Install the APCu extension
RUN pecl install apcu \
    && docker-php-ext-enable apcu
# Configure APCu
RUN echo "apc.enabled=1" >> /usr/local/etc/php/php.ini \
    && echo "apc.shm_size=256M" >> /usr/local/etc/php/php.ini \
    && echo "apc.ttl=7200" >> /usr/local/etc/php/php.ini \
    && echo "apc.enable_cli=0" >> /usr/local/etc/php/php.ini
# Copy default.settings.php to settings.php
RUN cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
# Append database configuration to settings.php
# Append hash salt to settings.php
# Append configuration sync directory to settings.php
RUN echo "\$databases['default']['default'] = array (" >> /var/www/html/sites/default/settings.php && \
    echo "  'database' => getenv('POSTGRES_DB')," >> /var/www/html/sites/default/settings.php && \
    echo "  'username' => getenv('POSTGRES_USER')," >> /var/www/html/sites/default/settings.php && \
    echo "  'password' => getenv('POSTGRES_PASSWORD')," >> /var/www/html/sites/default/settings.php && \
    echo "  'prefix' => ''," >> /var/www/html/sites/default/settings.php && \
    echo "  'host' => getenv('POSTGRES_HOST')," >> /var/www/html/sites/default/settings.php && \
    echo "  'port' => '5432'," >> /var/www/html/sites/default/settings.php && \
    echo "  'driver' => 'pgsql'," >> /var/www/html/sites/default/settings.php && \
    echo "  'namespace' => 'Drupal\\\\\\\\pgsql\\\\\\\\Driver\\\\\\\\Database\\\\\\\\pgsql'," >> /var/www/html/sites/default/settings.php && \
    echo "  'autoload' => 'core/modules/pgsql/src/Driver/Database/pgsql/'," >> /var/www/html/sites/default/settings.php && \
    echo ");" >> /var/www/html/sites/default/settings.php && \
    echo "\$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT');" >> /var/www/html/sites/default/settings.php && \
    echo "\$config_directories['sync'] = getenv('DRUPAL_CONFIG_SYNC_DIRECTORY');" >> /var/www/html/sites/default/settings.php
# Set file permissions
RUN chown -R www-data:www-data /var/www/html/sites/default/settings.php && \
    chmod 644 /var/www/html/sites/default/settings.php
# Docs
LABEL description="Single Dockerfile build of Drupal with drush and defaulted settings including Postgres"
LABEL version="1.0"