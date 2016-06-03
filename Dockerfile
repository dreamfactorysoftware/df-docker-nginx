FROM ubuntu:wily

MAINTAINER Arif Islam<arif@dreamfactory.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    git-core curl nginx php5-fpm php5-common php5-cli php5-curl php5-json php5-mcrypt php5-mysqlnd php5-pgsql php5-sqlite \
    php-pear php5-dev php5-ldap php5-mssql openssl pkg-config libpcre3-dev libv8-dev python nodejs python-pip zip

RUN apt-get install -y software-properties-common && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 && \
    add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main" && \
    apt-get update && \
    apt-get install -y hhvm && \
    /usr/share/hhvm/install_fastcgi.sh && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN pip install bunch

RUN pecl install mongodb && \
    echo "extension=mongodb.so" > /etc/php5/mods-available/mongodb.ini && \
    ln -s /etc/php5/mods-available/mongodb.ini /etc/php5/fpm/conf.d/21-mongodb.ini && \
    ln -s /etc/php5/mods-available/mongodb.ini /etc/php5/cli/conf.d/21-mongodb.ini

RUN pecl install v8js-0.1.3 && \
    echo "extension=v8js.so" > /etc/php5/mods-available/v8js.ini && \
    ln -s /etc/php5/mods-available/v8js.ini /etc/php5/fpm/conf.d/21-v8js.ini && \
    ln -s /etc/php5/mods-available/v8js.ini /etc/php5/cli/conf.d/21-v8js.ini

# Configure Nginx
RUN rm /etc/nginx/sites-enabled/default
ADD dreamfactory-nginx.conf /etc/nginx/sites-available/dreamfactory.conf
RUN ln -s /etc/nginx/sites-available/dreamfactory.conf /etc/nginx/sites-enabled/dreamfactory.conf
RUN rm /etc/php5/fpm/pool.d/www.conf
ADD www.conf /etc/php5/fpm/pool.d/www.conf

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
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Uncomment this is you are building for Bluemix and will be using ElephantSQL
#ENV BM_USE_URI=true

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
