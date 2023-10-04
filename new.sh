sudo su

sudo apt-get update
sudo apt update

timedatectl list-timezones | grep Kyiv
timedatectl set-timezone Europe/Kyiv
sed -i 's/#DNS=/DNS=8.8.8.8/g' /etc/systemd/resolved.conf
sed -i 's/#FallbackDNS=/FallbackDNS=8.8.4.4/g' /etc/systemd/resolved.conf
systemctl restart systemd-resolved

apt install -y mariadb-server 
apt install -y apache2 wget unzip 
apt install -y php php-zip php-json php-mbstring php-mysql
wget -q https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip -q phpMyAdmin-5.2.1-all-languages.zip && rm phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages /usr/share/phpmyadmin
mkdir /usr/share/phpmyadmin/tmp
chown -R www-data:www-data /usr/share/phpmyadmin

sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb
mariadb << EOT
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password;
ALTER USER 'root'@'localhost' IDENTIFIED BY '7X4pnluBS6pm';
CREATE USER 'root'@'%' IDENTIFIED BY '7X4pnluBS6pm';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
EOT
    tee -a /root/.my.cnf > /dev/null << EOT
[client]
user=root
password=7X4pnluBS6pm
EOT

echo -n "" > /etc/apache2/sites-available/000-default.conf
    tee -a /etc/apache2/sites-available/000-default.conf > /dev/null << EOT
<VirtualHost *:80>
    DocumentRoot /usr/share/phpmyadmin

    <Directory /usr/share/phpmyadmin>
        AllowOverride All
        Require all granted

        php_admin_value upload_max_filesize 1G
        php_admin_value post_max_size 1G
        php_admin_value max_execution_time 3600
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT
systemctl restart apache2


tee -a /usr/share/phpmyadmin/config.inc.php > /dev/null << EOT
<?php

declare(strict_types=1);

\\$cfg['blowfish_secret'] = 'dbf3c0a9855b283aa0129925a26c7a55';

\\$i = 0;
\\$i++;
\\$cfg['Servers'][\\$i]['auth_type'] = 'config';
\\$cfg['Servers'][\\$i]['user'] = 'root';
\\$cfg['Servers'][\\$i]['host'] = 'localhost';
\\$cfg['Servers'][\\$i]['password'] = '7X4pnluBS6pm';
\\$cfg['Servers'][\\$i]['compress'] = false;
\\$cfg['Servers'][\\$i]['AllowNoPassword'] = false;

\\$cfg['UploadDir'] = '';
\\$cfg['SaveDir'] = '';
EOT
