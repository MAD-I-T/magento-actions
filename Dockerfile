FROM debian:buster

LABEL org.opencontainers.image.source="https://github.com/MAD-I-T/magento-actions"



RUN echo 'deb  http://deb.debian.org/debian  buster contrib non-free' >> /etc/apt/sources.list
RUN echo 'deb-src  http://deb.debian.org/debian  buster contrib non-free' >> /etc/apt/sources.list


RUN apt-get -y update \
    && apt-get -y install \
    apt-transport-https \
    ca-certificates \
    wget


RUN apt-get -yq install \
    python-pip\
    gcc\
    python-dev

RUN wget -O "/etc/apt/trusted.gpg.d/php.gpg" "https://packages.sury.org/php/apt.gpg" \
    && sh -c 'echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list'

RUN apt-get install -f libgd3 -y

RUN apt-get -y update \
    && apt-get -y install \
    git \
    curl \
    php7.1-cli \
    php7.1-curl \
    php7.1-dev \
    php7.1-gd \
    php7.1-intl \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-mbstring \
    php7.1-xml \
    php7.1-xsl \
    php7.1-zip \
    php7.1-json \
    php7.1-soap \
    php7.1-bcmath \
    php7.2 \
    php7.2-common \
    php7.2-cli \
    php7.2-curl \
    php7.2-dev \
    php7.2-gd \
    php7.2-intl \
    php7.2-mysql \
    php7.2-mbstring \
    php7.2-xml \
    php7.2-xsl \
    php7.2-zip \
    php7.2-json \
    php7.2-xdebug \
    php7.2-soap \
    php7.2-bcmath \
    php7.3 \
    php7.3-common \
    php7.3-cli \
    php7.3-curl \
    php7.3-dev \
    php7.3-gd \
    php7.3-intl \
    php7.3-mysql \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-xsl \
    php7.3-zip \
    php7.3-json \
    php7.3-xdebug \
    php7.3-soap \
    php7.3-bcmath \
    php7.4 \
    php7.4-common \
    php7.4-cli \
    php7.4-curl \
    php7.4-dev \
    php7.4-gd \
    php7.4-intl \
    php7.4-mysql \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-xsl \
    php7.4-zip \
    php7.4-json \
    php7.4-xdebug \
    php7.4-soap \
    php7.4-bcmath \
    php8.1 \
    php8.1-common \
    php8.1-cli \
    php8.1-curl \
    php8.1-dev \
    php8.1-gd \
    php8.1-intl \
    php8.1-mysql \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-xsl \
    php8.1-zip \
    php8.1-xdebug \
    php8.1-soap \
    php8.1-bcmath \
    php8.2 \
    php8.2-common \
    php8.2-cli \
    php8.2-curl \
    php8.2-dev \
    php8.2-gd \
    php8.2-intl \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-xsl \
    php8.2-zip \
    php8.2-xdebug \
    php8.2-soap \
    php8.2-bcmath \
    zip \
    default-mysql-client \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/doc \
    /usr/share/doc-base

RUN curl -LO https://getcomposer.org/composer-stable.phar \
    && mv ./composer-stable.phar ./composer.phar \
    && chmod +x ./composer.phar \
    && mv ./composer.phar /usr/local/bin/composer\
    && php7.2 /usr/local/bin/composer self-update --2

COPY LICENSE README.md /
COPY scripts /opt/scripts
COPY config /opt/config
COPY entrypoint.sh /entrypoint.sh

RUN cd /opt/config/php-deployer/ &&  /usr/bin/php7.4 /usr/local/bin/composer install

RUN  mkdir /opt/magerun/ \
    && cd /opt/magerun/ \
    && curl -sS -O https://files.magerun.net/n98-magerun2-latest.phar \
    && curl -sS -o n98-magerun2-latest.phar.sha256 https://files.magerun.net/sha256.php?file=n98-magerun2-latest.phar \
    && shasum -a 256 -c n98-magerun2-latest.phar.sha256

ENTRYPOINT ["/entrypoint.sh"]
