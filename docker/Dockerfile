FROM php:7.3.3-fpm

ENV TIMEZONE=UTC

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    vim \
    zlib1g-dev \
    libzip-dev \
    zip \
    libicu-dev \
    libpq-dev \
    unzip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    nginx && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) \
    gd \
    bcmath \
    opcache \
    pdo_pgsql \
    zip \
    intl && \
    echo $TIMEZONE > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt install -y --no-install-recommends procps && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files /

WORKDIR /var/www/

CMD ["sh", "-c", "nginx -g \"daemon off;\" & php-fpm"]
