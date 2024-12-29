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

# php extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync
RUN install-php-extensions zip pdo_mysql gd soap

# install node 8 because newever version go kaboom
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs npm &&\
    apt-get clean

#install ldview
RUN wget https://github.com/tcobbs/ldview/releases/download/v4.4/ldview-osmesa-4.4-debian-buster.amd64.deb -O /ldview-osmesa-4.4-debian-buster.amd64.deb
RUN apt install -y /ldview-osmesa-4.4-debian-buster.amd64.deb --allow-unauthenticated && \
    rm /ldview-osmesa-4.4-debian-buster.amd64.deb && \
    apt-get clean
# rebuild mesa for debian:buster
# https://github.com/tcobbs/ldview/issues/40
RUN wget https://archive.mesa3d.org/mesa-18.3.6.tar.xz && \
tar Jxf mesa-18.3.6.tar.xz
RUN apt install -y\
        build-essential meson python3-mako \
        libexpat1-dev libdrm-dev llvm-dev libelf-dev \
        bison flex \
        libwayland-dev wayland-protocols libwayland-egl-backend-dev \
        libx11-dev libxext-dev libxdamage-dev libxcb-glx0-dev libx11-xcb-dev\
        libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev libxshmfence-dev libxxf86vm-dev libxrandr-dev \
        gettext &&\
    apt-get clean
RUN cd mesa-18.3.6 && \
    mkdir builddir && \
    meson builddir && \
    ninja -C builddir && \
    ninja -C builddir/ install && \
    export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu
RUN rm mesa-18.3.6.tar.xz && rm mesa-18.3.6 -r

# install stl2pov
RUN git clone https://github.com/rsmith-nl/stltools.git
WORKDIR stltools
RUN python3 setup.py install
WORKDIR /

# install composer
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

# Print a Brick
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
    build-essential meson python3-mako \
    libexpat1-dev libdrm-dev llvm-dev libelf-dev \
    bison flex \
    libwayland-dev wayland-protocols libwayland-egl-backend-dev \
    libx11-dev libxext-dev libxdamage-dev libxcb-glx0-dev libx11-xcb-dev \
    libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev libxshmfence-dev libxxf86vm-dev libxrandr-dev \
    gettext \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean