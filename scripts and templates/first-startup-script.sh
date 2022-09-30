#!/bin/bash
FILE=/bin/test-if-first-boot-up-then-exist.txt
# BUCKET=terr-custom-bucket
if test ! -f "$FILE" ; then
 touch "$FILE"
 apt-get -y install apache2
 apt-get -y install libapache2-mod-php
 apt-get -y install php-mysql
 apt-get install mysql-client-core-8.0
 gsutil -m cp -R gs://terr-custom-bucket/php-mysql-crud-master/ /var/www/html/
 mv /var/www/html/php-mysql-crud-master/* /var/www/html/
 mv /var/www/html/index.html /var/www/html/default-apache-index.html
 mysql --host=${sql_server_ip} --user=${sql_user_name} --password=${sql_user_password} ${sql_db_name} < ${sql_path_to_cript}
 systemctl restart apache2
fi