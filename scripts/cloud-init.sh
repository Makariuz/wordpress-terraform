#!/bin/bash

set -e

DB_PASS="${DB_PASSWORD}"
DB="${DB_NAME}"
USER="${DB_USER}"

 apt-get update -y
 apt-get upgrade -y
 apt-get install nginx -y

 systemctl start nginx 

 apt-get install mysql-server -y

 systemctl start mysql

 apt-get install php-fpm php-mysql -y

cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;
    listen [::]:80;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name makariuz.xyz www.makariuz.xyz;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

nginx -t
/etc/init.d/nginx reload


service mysql start

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $DB;
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB.* TO '$USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username:   $USER"
echo "Password:   $DB_PASS"


wget -P /tmp https://wordpress.org/latest.tar.gz
tar -zxvf /tmp/latest.tar.gz -C /tmp
cp -r /tmp/wordpress/* /var/www/html
chown -R www-data:www-data /var/www/html