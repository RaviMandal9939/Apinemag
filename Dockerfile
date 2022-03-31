FROM alpine:3.12
RUN apk update && apk add nginx openrc php7 shadow nano curl vim git tree php7-fpm php7-bcmath php7-cli php7-ctype php7-curl php7-dom php7-fpm php7-gd php7-iconv php7-intl php7-json php7-mbstring php7-mcrypt php7-openssl php7-pdo_mysql php7-phar php7-session php7-simplexml php7-soap php7-tokenizer php7-xml php7-xmlwriter php7-xsl php7-zip php7-zlib php7-sockets php7-sodium php7-fileinfo &&\
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
php composer-setup.php && php -r "unlink('composer-setup.php');" &&\
mv composer.phar /usr/local/bin/composer &&\
apk update && apk add wget axel bash net-tools openssl openjdk11 && rm -rf /var/cache/apk/* &&\
axel https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.0-linux-x86_64.tar.gz && tar -xf  elasticsearch-7.9.0-linux-x86_64.tar.gz -C /usr/share/ \
    && echo -e "export ES_JAVA_HOME=/usr/lib/jvm/java-11-openjdk\nexport JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> /etc/profile \
    && mv /usr/share/elasticsearch-7.9* /usr/share/elasticsearch \
#   && mkdir /usr/share/elasticsearch/logs \
    && mkdir /usr/share/elasticsearch/data \
    && mkdir /usr/share/elasticsearch/config/scripts \
    && adduser -D -u 1000 -h /usr/share/elasticsearch elasticsearch \
    && chown -R elasticsearch /usr/share/elasticsearch \
    && rm -rf /usr/share/elasticsearch/modules/x-pack-ml \ 
    && rm -rf /var/www/magento \
    &&  apk update && \
	apk add mysql mysql-client && \
	addgroup mysql mysql && \
	mkdir /scripts && \
	rm -rf /var/cache/apk/*
#VOLUME ["/var/lib/mysql"]
COPY auth.json /root/.composer/auth.json
COPY startup.sh /startup.sh
#COPY auth.json /var/www/html/magento/var/composer_home/auth.json
COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY default.conf /etc/nginx/conf.d/default.conf
#RUN chmod +x /scripts/startup.sh
#mv /var/lib/mysql /tmp
WORKDIR /var/www/html/magento
ENTRYPOINT ["/startup.sh"]
COPY php.ini /etc/php7/php.ini
EXPOSE 9200 9300 3306 80
