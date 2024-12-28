#!/bin/bash
# php bin/console doctrine:database:create # not needed since mariadb creates it for us
php bin/console doctrine:schema:drop --force
php bin/console doctrine:schema:create
php bin/console doctrine:fixtures:load
php -d memory_limit=2G bin/console app:init --env=prod
# nginx -g 'daemon off;'