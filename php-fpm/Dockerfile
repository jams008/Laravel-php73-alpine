FROM php:7.3-fpm-alpine

ENV NAME_REPO monitoring
ENV SSH_PORT 57713
ENV SSH_PASSWORD testtest

# persistent dependencies
RUN apk add --no-cache \
# in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
		bash \
# BusyBox sed is not sufficient for some of our sed expressions
		sed \
# Ghostscript is required for rendering PDF previews
		ghostscript \
# Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
		imagemagick

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		freetype-dev \
		imagemagick-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		mysqli \
		zip \
	; \
	pecl install imagick-3.4.4; \
	docker-php-ext-enable imagick; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .wordpress-phpexts-rundeps $runDeps; \
	apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
	docker-php-ext-enable opcache; \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
# https://wordpress.org/support/article/editing-wp-config-php/#configure-error-logging
RUN { \
# https://www.php.net/manual/en/errorfunc.constants.php
# https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /usr/local/etc/php/conf.d/error-logging.ini

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk add --no-cache --virtual .build-deps \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    openssh \
    tzdata \
    supervisor;

# Custom user for application
RUN apk --no-cache add shadow && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data

# setup ssh config
RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
&& echo 'root:'${SSH_PASSWORD} | chpasswd \
&& echo 'www-data:'${SSH_PASSWORD} | chpasswd \
&& rm -rf /var/cache/apk/* \
&& sed -ie 's/#Port 22/Port '${SSH_PORT}'/g' /etc/ssh/sshd_config \
&& sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config \
&& sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config \
&& sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config \
&& sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config \
&& sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config \
&& /usr/bin/ssh-keygen -A \
&& ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key 

# Create Directory repo
RUN mkdir -p /repo/${NAME_REPO}.git

# Setup Repo
RUN cd /repo/${NAME_REPO}.git && git init --bare 
# Generate Post-receive git bare
RUN echo "#!/bin/sh" >> /repo/${NAME_REPO}.git/hooks/post-receive && \
echo 'git --work-tree=/var/www --git-dir=/repo/'${NAME_REPO}'.git checkout master -f' >> /repo/${NAME_REPO}.git/hooks/post-receive && \
echo "echo tonjootonjoo| sudo -S chown -R www-data: /var/ww" >> /repo/${NAME_REPO}.git/hooks/post-receive 
RUN chmod +x /repo/${NAME_REPO}.git/hooks/post-receive && \
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
# Change permission Folder
chmod -R 775 /var/www && chown -R www-data:www-data /var/www

# setup script start
COPY ./start.sh /start.sh
RUN chmod +x /start.sh

# Change current user to www
#USER www-data

EXPOSE 9000 57713

# Start process file
CMD ["/start.sh"]