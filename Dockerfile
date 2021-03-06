FROM php:5.6-apache
MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Install PHP extensions
RUN apt-get update && apt-get install -y libc-client-dev libicu-dev libkrb5-dev libmcrypt-dev libssl-dev unzip zip cron libmemcached-dev libz-dev git
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip
RUN git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached
RUN docker-php-ext-configure memcached
RUN docker-php-ext-install memcached

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 1.4.1

# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://s3.amazonaws.com/mautic/releases/${MAUTIC_VERSION}.zip \
	&& mkdir /usr/src/mautic \
	&& unzip mautic.zip -d /usr/src/mautic \
	&& rm mautic.zip \
	&& chown -R www-data:www-data /usr/src/mautic

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php

COPY crons.conf /crons.conf
RUN /usr/bin/crontab /crons.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
