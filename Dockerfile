# Set the base image
FROM mautic/mautic

# File Author / Maintainer
MAINTAINER Marcos Sanz <marcos.sanz@13genius.com>

RUN apt-get update && apt-get install -y cron libmemcached-dev libz-dev
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-configure memcached
RUN docker-php-ext-install zip memcached

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 1.4.0
ENV MAUTIC_SHA1 da91683b3b7b9ea2e4eb39525a47a89bbf20c75d

COPY crons.conf /crons.conf
RUN /usr/bin/crontab /crons.conf
