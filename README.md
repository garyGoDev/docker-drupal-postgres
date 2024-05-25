# Dockerized Drupal with Drush and Postgres

This Dockerfile creates a Docker image for a Drupal application with Drush and Postgres support. It is based on the official Drupal image and includes additional configurations and extensions to support a more robust Drupal development environment.

[![docker-build](https://github.com/garyGoDev/docker-drupal-postgres/actions/workflows/docker-build.yml/badge.svg)](https://github.com/garyGoDev/docker-drupal-postgres/actions/workflows/docker-build.yml)

[DockerHub cloudgrounds/drupal-postgres](https://hub.docker.com/r/cloudgrounds/drupal-postgres)

## Features

- Based on `drupal:10.2.6-php8.2-apache-bookworm` image from [the official Drupal image](https://hub.docker.com/_/drupal/)
- Includes Drush, a command-line shell and scripting interface for Drupal
- Configured to use Postgres as the database
- Includes APCu PHP extension for caching
- Configures PHP for output buffering
- Sets up default Drupal settings and file permissions

## Usage

To build the Docker image, navigate to the directory containing the Dockerfile and run:

```bash
docker build -t your-custom-image:1.0 .
```

To run drupal from the image use `docker compose` with the example file

```bash
HASH_SALT=yourreallyreallylongandrandomhash DRUPAL_ADMIN_PASS=yourfirstsupersafepassword POSTGRES_PASSWORD=yourothersupersafepassword docker-compose up -d
```

## Environment Variables

The Dockerfile uses the following environment variables:

- `POSTGRES_DB`: The name of your Postgres database
- `POSTGRES_USER`: The username for your Postgres database
- `POSTGRES_PASSWORD`: The password for your Postgres database
- `POSTGRES_HOST`: The host of your Postgres database
- `DRUPAL_HASH_SALT`: The hash salt for your Drupal application
- `DRUPAL_CONFIG_SYNC_DIRECTORY`: The directory for Drupal configuration synchronization files. This should be outside web root. This defaults to `/var/configsync`
- `DRUPAL_ADMIN_USER`: The username for your Drupal admin account
- `DRUPAL_ADMIN_PASS`: The password for your Drupal admin account
- `DRUPAL_ADMIN_EMAIL`: The email for your Drupal admin account

## Volumes

The Dockerfile specifies volumes for the Drupal installation and files directories. This allows you to persist data across container restarts and share data between containers. See the **Volumes** section in the official Drupal image.

## Entrypoint Script

The `entrypoint.sh` script is executed when the Docker container starts. It performs several checks and operations to ensure the Drupal site is properly set up.

### Script Overview

The script performs the following operations:

1. Checks the status of the database connection and Drupal bootstrap using [Drush](https://www.drush.org/).
2. If the database is not connected and Drupal is not bootstrapped, it installs the Drupal site using the `drush site-install` command.
3. If the database is connected or Drupal is bootstrapped, it updates the database using the `drush updatedb` command and rebuilds the cache using the `drush cache-rebuild` command.
4. Finally, it executes the command passed to the `docker run` command.

Environment variables are included above and should be set in your Docker environment or in your `docker-compose.yml` file.

### Drush

[Drush](https://www.drush.org/) is a command-line shell and Unix scripting interface for Drupal. Drush core ships with lots of useful commands for interacting with code like modules/themes/profiles. Similarly, it runs update.php, executes SQL queries and DB migrations, and misc utilities like run cron or clear cache.

For more information about the Drush commands used in this script, see the following links:

- [drush status](https://www.drush.org/13.x/commands/core_status/)
- [drush site-install](https://www.drush.org/13.x/commands/site_install/)
- [drush updatedb](https://www.drush.org/13.x/commands/updatedb/)
- [drush cache-rebuild](https://www.drush.org/13.x/commands/cache_rebuild/)

## Running Apache

By default, the Docker container will run Apache in the foreground.

## Versions

Versions are based on the run number in the GitHub Actions publication workflow.