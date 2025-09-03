#!/bin/bash
# docker exec -it printabrick-nginx-1 bash
# init
# php bin/console doctrine:database:create # not needed since mariadb creates it for us
php bin/console doctrine:schema:drop --force
php bin/console doctrine:schema:create
php bin/console doctrine:fixtures:load

# start
# generate parameters.yml with composer
# composer install --no-dev --no-interaction --no-scripts
# composer run-script symfony-scripts --no-dev

# update
# wget https://library.ldraw.org/library/updates/complete.zip
# unzip -d /tmp/ complete.zip
# rm complete.zip
php -d memory_limit=4G bin/console app:init --env=prod -l /tmp/ldraw
# rm -r /tmp/ldraw
php bin/console app:load:ldraw --env=prod --all -l /tmp/ldraw # update stl models
php -d memory_limit=2G bin/console app:load:rebrickable --env=prod
# php bin/console fos:elastica:populate
php -d memory_limit=2G bin/console app:load:images --missing --env=prod