#!/bin/bash
# exit on error
set -e
# get drush status for checking if the site is installed
DB_STATUS=$(drush status | grep "Database" | awk '{print $NF}')
echo "Database connected: $DB_STATUS"
DRUPAL_BOOTSTRAP_STATUS=$(drush status | grep "Drupal bootstrap" | awk '{print $NF}')
echo "Drupal bootstrap: $DRUPAL_BOOTSTRAP_STATUS"
# check if the site is installed
if [ "$DB_STATUS" != "Connected" ] && [ "$DRUPAL_BOOTSTRAP_STATUS" != "Successful" ]; then
    drush site-install standard --db-url=pgsql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:5432/$POSTGRES_DB --site-name=$DRUPAL_SITE_NAME --account-name=$DRUPAL_ADMIN_USER --account-pass=$DRUPAL_ADMIN_PASS --account-mail=$DRUPAL_ADMIN_EMAIL --no-interaction
fi
# if the site is installed, run drush updatedb and cache-rebuild
if [ "$DB_STATUS" == "Connected" ] || [ "$DRUPAL_BOOTSTRAP_STATUS" == "Successful" ]; then
    drush updatedb --no-interaction
    drush cache-rebuild
fi
# run the command passed to the docker run
exec "$@"