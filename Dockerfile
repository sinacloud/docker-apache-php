FROM php:7.2-apache
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

RUN a2enmod rewrite && \
    a2enmod remoteip && \
    { \
        echo 'RemoteIPHeader X-Forwarded-For'; \
        echo 'RemoteIPInternalProxy 10.0.0.0/8'; \
        echo 'RemoteIPInternalProxy 172.16.0.0/12'; \
        echo 'RemoteIPInternalProxy 192.168.0.0/16'; \
        echo 'RemoteIPInternalProxy 169.254.0.0/16'; \
        echo 'RemoteIPInternalProxy 127.0.0.0/8'; \
    } | tee "$APACHE_CONFDIR/conf-available/remoteip.conf" && \
    a2enconf remoteip

RUN apt-get update && apt-get install -y libbz2-dev libfreetype6-dev  \
    libjpeg62-turbo-dev libmcrypt-dev libpng-dev libmemcached-dev libicu-dev \
    libzip-dev \
    libedit-dev libtidy-dev && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath bz2 calendar exif gd gettext intl \
    mysqli opcache pdo pdo_mysql readline sockets tidy
RUN pecl install redis-3.1.5 && \
    pecl install memcached-3.0.4 && \
    pecl install mcrypt-1.0.1 && \
    pecl install zlib zip && \
    docker-php-ext-enable redis memcached zip mcrypt

RUN echo '\
post_max_size = 160M\n\
upload_max_filesize = 128M\n\
memory_limit = 256M\n\
' >> /usr/local/etc/php/php.ini