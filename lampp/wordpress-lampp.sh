#!/bin/bash

WP_PATH=/opt/lampp/htdocs
LAMP_VERSION=7.3.4

##################################################
## Script per la instal·lació de lamp + wordpress
##################################################

## Comprovem que hem fet sudo
if [ "$EUID" -ne 0 ]; then
    echo "Usage: sudo $(basename $0)"
    exit
fi

## Comprovem que no existeix ja una versió de wordpress instal·lada:
if [ -d $WP_PATH/wordpress ]; then
    echo "Sembla que ja tens una versió de wordpress instal·lada a $WP_PATH"
    exit
fi

## XAMPP versio 7.4.2

echo "Downloading lamp $LAMP_VERSION This may take a while..."
wget -q --show-progress https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/$LAMP_VERSION/xampp-linux-x64-$LAMP_VERSION-0-installer.run

chmod u+x xampp-linux-x64-$LAMP_VERSION-0-installer.run

echo "Instaling lamp"
sudo ./xampp-linux-x64-$LAMP_VERSION-0-installer.run --mode unattended

## wordpress (latest version)
wget -q --show-progress -c http://wordpress.org/latest.tar.gz
sleep 1
tar -xf latest.tar.gz
sudo mv wordpress $WP_PATH

## mysql
sudo apt -qq update
sudo apt -qq -y install mysql-client

echo "creating mysql database"
sleep 1
mysqlstat=$(/opt/lampp/mysql/scripts/ctl.sh status)
if [ "mysql not runnung"="$mysqlstat" ]; then
    sudo /opt/lampp/mysql/scripts/ctl.sh start
fi

## Creem la base de dades per wordpress
mysql -h 127.0.0.1 -P 3306 -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -h 127.0.0.1 -P 3306 -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO wp@localhost IDENTIFIED BY 'wp';"
mysql -h 127.0.0.1 -P 3306 -u root -e "FLUSH PRIVILEGES;"

echo "---------------------------------------------------"
echo "database wordpress created for user wp and pwd 'wp'"
echo "---------------------------------------------------"

sudo chown -R daemon:daemon  $WP_PATH/wordpress
sudo chmod -R 755  $WP_PATH/wordpress


firefox http://localhost/wordpress


