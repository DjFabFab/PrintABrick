# ldview is broken in debian:buster!, requires bullseye
# node > 8 for bullseye
FROM php:7.1.33-fpm-buster
# FROM php:7.1.33-fpm-stretch

ENV PHP_MEMORY_LIMIT=2G

RUN apt update && apt-get upgrade -y && apt install -y \
    admesh \
    apt-transport-https \
    git \
    gnupg \
    libzip-dev \
    povray \
    python3-setuptools \
    vim \
    wget \
    zstd \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# RUN COPY docker-php-ext-get /usr/local/bin/

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync

RUN install-php-extensions zip pdo_mysql gd soap

# install elasticsearch
# RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
# RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
# RUN apt update && apt install elasticsearch

# RUN /bin/systemctl enable elasticsearch.service

#install node 8 because newever version go kaboom
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs npm &&\
    apt-get clean

#install ldview
# RUN sed -i 's/buster main/bullseye main/g' /etc/apt/sources.list && apt update --allow-unauthenticated
# RUN apt-get upgrade --allow-unauthenticated -y
RUN wget https://github.com/tcobbs/ldview/releases/download/v4.4/ldview-osmesa-4.4-debian-buster.amd64.deb -O /ldview-osmesa-4.4-debian-buster.amd64.deb
RUN apt install -y /ldview-osmesa-4.4-debian-buster.amd64.deb --allow-unauthenticated && \
    rm /ldview-osmesa-4.4-debian-buster.amd64.deb && \
    apt-get clean
# RUN sed -i 's/bullseye main/buster main/g' /etc/apt/sources.list && apt update
# RUN wget https://github.com/tcobbs/ldview/releases/download/v4.4/ldview-osmesa-4.4-1-x86_64.pkg.tar.zst -O /ldview-osmesa-4.4-1-x86_64.pkg.tar.zst
# RUN tar --zstd -xvf /ldview-osmesa-4.4-1-x86_64.pkg.tar.zst
# RUN wget https://archive.debian.org/debian/pool/main/libj/libjpeg8/libjpeg8_8b-1_amd64.deb
# RUN apt-get install ./libjpeg8_8b-1_amd64.deb && rm ./libjpeg8_8b-1_amd64.deb
# RUN apt install -y libgl2ps1.4 libpng16-16 libosmesa6 libglu1-mesa libtinyxml-dev && apt-get clean && \
#     ln -s /usr/lib/x86_64-linux-gnu/libgl2ps.so.1.4 /usr/lib/x86_64-linux-gnu/libgl2ps.so.1 && \
#     ln -s /usr/lib/x86_64-linux-gnu/libtinyxml.so.2.6.2 /usr/lib/x86_64-linux-gnu/libtinyxml.so.0


#install stl2pov
RUN git clone https://github.com/rsmith-nl/stltools.git
WORKDIR stltools
RUN python3 setup.py install
WORKDIR /

#install composer
RUN wget https://getcomposer.org/installer
RUN php installer
RUN mv composer.phar /usr/local/bin/composer

# Install & configure nginx
RUN apt update && apt install -y \
    nginx &&\
    apt-get clean
# ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-site.conf /etc/nginx/sites-available/default
    

# Configure fpm
ADD fpm.conf /etc/php/7.1/fpm/pool.d/printabrick.conf

# RUN git clone https://github.com/hubnedav/PrintABrick.git
ADD . /PrintABrick
WORKDIR /PrintABrick
RUN composer install

# setup front ned
RUN npm install
RUN npm install bower -g

RUN bower install --allow-root
RUN node_modules/gulp/bin/gulp.js

# Permissions
#

RUN chown -R www-data:www-data .

RUN mkdir -p web/media/cache
RUN chown -R root:www-data web
RUN chmod -R 775 web/media/cache
# RUN chmod -R +xx web

RUN mkdir -p var/cache
RUN chown -R root:www-data var
RUN chmod -R 775 var
# RUN chmod -R 775 var/logs
# RUN chmod -R 775 var/sessions
# RUN chmod -R 775 var/cache

RUN chown -R root:www-data vendor
RUN chmod -R +xx vendor

# RUN apt install -y mysql-server
# RUN apt install -y mariadb-client
#configure mysql
#start and let root access to server

#RUN php bin/console doctrine:database:create
#RUN php bin/console doctrine:schema:create

#RUN php bin/console doctrine:fixtures:load

#RUN php bin/console app:init

# Cleanup
RUN apt remove --autoremove -y \
    apt-transport-https \
    git \
    vim \
    wget \
    zstd \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean