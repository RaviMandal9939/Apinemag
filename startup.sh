#!/bin/sh
#elasticsearch
su - elasticsearch -c /usr/share/elasticsearch/bin/elasticsearch > /dev/null 2>&1 & 

#mysql
if [ ! -d "/run/mysqld" ]; then
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
fi
chown -R mysql:mysql /var/lib/mysql
echo 'Initializing database'
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null
tfile=`mktemp`
if [ ! -f "$tfile" ]; then
return 1
fi
# save sql
echo "[i] Create temp file: $tfile"
cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
EOF
echo "[i] Creating database: magento"
echo "CREATE DATABASE IF NOT EXISTS magento CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
echo "GRANT ALL ON magento.* to 'magento'@'%' IDENTIFIED BY 'magento';" >> $tfile
echo 'FLUSH PRIVILEGES;' >> $tfile
echo 'SET GLOBAL log_bin_trust_function_creators = 1;' >> $tfile
echo "[i] run tempfile: $tfile"
/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
rm -f $tfile
echo "[i] Sleeping 5 sec"
sleep 5
echo "Starting all process"
exec /usr/bin/mysqld --user=mysql --console --log-bin-trust-function-creators=1 &




#php
#!/bin/bash
composer create-project --no-interaction --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.3 /var/www/html/magento  
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + && chown -R :www-data . && chmod u+x bin/magento && chmod -R 777 var generated && php bin/magento setup:install --base-url=http://magealpinerv.com/ --db-host=localhost --db-name=magento --db-user=magento --db-password=magento --admin-firstname=admin --admin-lastname=admin --admin-email=admin@admin.com --admin-user=admin --admin-password=admin123 --language=en_US --currency=USD --timezone=Asia/Kolkata --use-rewrites=1 && cp /root/.composer/auth.json /var/www/html/magento/var/composer_home/auth.json &&  php -d memory_limit=-1 bin/magento sampledata:deploy && php bin/magento se:up && php bin/magento module:disable Magento_TwoFactorAuth &&  php bin/magento module:disable Magento_TwoFactorAuth  && php bin/magento setup:static-content:deploy -f && php bin/magento c:c && php bin/magento c:f

watch netstat -tulpn
