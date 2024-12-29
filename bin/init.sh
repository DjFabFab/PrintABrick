#!/bin/bash
# docker exec -it printabrick-nginx-1 bash
# php bin/console doctrine:database:create # not needed since mariadb creates it for us
php bin/console doctrine:schema:drop --force
php bin/console doctrine:schema:create
php bin/console doctrine:fixtures:load
php -d memory_limit=2G bin/console app:init --env=prod
# nginx -g 'daemon off;'

#start
php bin/console app:load:ldraw --env=prod --all --update
php -d memory_limit=2G bin/console app:load:images --missing --env=prod