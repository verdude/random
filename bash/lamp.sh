#!/bin/bash
sudo apt-get update
sudo apt-get -y install apache2
# ifconfig eth0 | grep inet | awk '{ print $2 }'
sudo apt-get -y install mysql-server
sudo mysql_secure_installation
sudo apt-get install php5 php-pear php5-mysql
sudo service apache2 restart