#!/bin/bash
# docker exec -it printabrick-nginx-1 bash
# php bin/console doctrine:database:create # not needed since mariadb creates it for us
php bin/console doctrine:schema:drop --force
php bin/console doctrine:schema:create
php bin/console doctrine:fixtures:load
# wget https://library.ldraw.org/library/updates/complete.zip
# unzip -d /tmp/ complete.zip
# rm complete.zip
php -d memory_limit=4G bin/console app:init --env=prod -l /tmp/ldraw
# rm -r /tmp/ldraw
# nginx -g 'daemon off;'

#start
php bin/console app:load:ldraw --env=prod --all -l /tmp/ldraw # update stl models
php -d memory_limit=2G bin/console app:load:rebrickable --env=prod
php -d memory_limit=2G bin/console app:load:images --missing --env=prod
php bin/console fos:elastica:populate