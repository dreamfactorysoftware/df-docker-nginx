FROM ubuntu:xenial

MAINTAINER Arif Islam<arif@dreamfactory.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    git-core curl nginx php7.0-fpm php7.0-common php7.0-cli php7.0-curl php7.0-json php7.0-mcrypt php7.0-mysqlnd php7.0-pgsql php7.0-sqlite \
    php-pear php7.0-dev php7.0-ldap php7.0-sybase php7.0-mbstring php7.0-zip php7.0-soap openssl pkg-config python nodejs python-pip zip

RUN rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN pip install bunch

RUN pecl install mongodb && \
    echo "extension=mongodb.so" > /etc/php/7.0/mods-available/mongodb.ini && \
    phpenmod mongodb

RUN mkdir -p /usr/lib /usr/include
ADD v8/usr/lib/libv8* /usr/lib/
ADD v8/usr/include /usr/include/
ADD v8/usr/lib/php/20151012/v8js.so /usr/lib/php/20151012/v8js.so
RUN echo "extension=v8js.so" > /etc/php/7.0/mods-available/v8js.ini && phpenmod v8js

# Configure Nginx/php-fpm
RUN rm /etc/nginx/sites-enabled/default
ADD dreamfactory-nginx.conf /etc/nginx/sites-available/dreamfactory.conf
RUN ln -s /etc/nginx/sites-available/dreamfactory.conf /etc/nginx/sites-enabled/dreamfactory.conf && \
    sed -i "s/pm.max_children = 5/pm.max_children = 5000/" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/pm.start_servers = 2/pm.start_servers = 150/" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 100/" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 200/" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s/worker_connections 768;/worker_connections 2048;/" /etc/nginx/nginx.conf && \
    sed -i "s/keepalive_timeout 65;/keepalive_timeout 10;/" /etc/nginx/nginx.conf

# install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# get app src
RUN git clone https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory

WORKDIR /opt/dreamfactory

# Uncomment this line if you're building for Bluemix and/or using redis for your cache
#RUN composer require "predis/predis:~1.0"

# install packages
RUN composer install

RUN php artisan dreamfactory:setup --no-app-key --db_driver=mysql --df_install=Docker

RUN chown -R www-data:www-data /opt/dreamfactory

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Uncomment this is you are building for Bluemix and will be using ElephantSQL
#ENV BM_USE_URI=true

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
