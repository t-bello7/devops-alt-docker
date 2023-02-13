FROM php:apache

ARG user=user1
ARG uid=1000

RUN apt-get update && apt-get install -y \
    git \ 
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    vim

RUN apt-get update

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& composer --version

COPY ./src/ /var/www/html/
RUN chmod -R 755 /var/www/html/storage/logs/
# RUN chmod -R 755 /var/www/html/
# RUN chown -R www-data:www-data /var/www/html/

WORKDIR /var/www/html

RUN composer install --ignore-platform-reqs
RUN php artisan config:clear 
RUN composer update --ignore-platform-reqs

COPY ./apache/laravel.conf /etc/apache2/sites-available/laravel.conf
COPY ./.env /var/www/html/.env
RUN a2ensite laravel.conf
RUN a2enmod rewrite
RUN a2dissite 000-default.conf

RUN php artisan config:clear
RUN php artisan key:generate
RUN php artisan cache:clear
RUN php artisan route:clear
RUN php artisan view:clear

EXPOSE 3001