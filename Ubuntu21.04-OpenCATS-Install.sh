#!/bin/sh
# This script will install a new OpenCATS instance on a fresh Ubuntu 21.04 server.
# This script is experimental and does not ensure any security.


export DEBIAN_FRONTEND=noninteractive
apt update
add-apt-repository -y ppa:ondrej/php
apt update
apt upgrade -y
apt install -y mariadb-server mariadb-client apache2 php7.2 php7.2-soap php7.2-ldap php7.2-mysql php7.2-gd php7.2-xml php7.2-curl php7.2-mbstring php7.2-zip antiword poppler-utils html2text unrtf

# Set up database
mysql -u root --execute="CREATE DATABASE cats_dev;"
mysql -u root --execute="CREATE USER 'cats'@'localhost' IDENTIFIED BY 'password';"
mysql -u root --execute="GRANT ALL PRIVILEGES ON cats_dev.* TO 'cats'@'localhost';"

# Download OpenCATS
cd /var/www/html
wget https://github.com/opencats/OpenCATS/releases/download/0.9.6/opencats-0.9.6-full.zip
unzip opencats-0.9.6-full.zip
mv /var/www/html/home/travis/build/opencats/OpenCATS/ .
mv OpenCATS opencats

# Install composer
# apt install -y composer
 cd /var/www/html/opencats
# Not for 0.9.6

# Install OpenCATS composer dependencies
# composer install

cd ..

# Set file and folder permissions
chown www-data:www-data -R opencats && chmod -R 770 opencats/attachments opencats/upload

# Restart Apache to load new config
service apache2 restart

# remove install_block
rm -dfr /var/www/html/opencats/INSTALL_BLOCK

echo ""
echo "Setup Finished, Your OpenCATS applicant tracking system should now be installed."
echo "MySQL was installed without a root password, It is recommended that you set a root MySQL password."
echo ""
echo "The database has been created as cats_dev, the user is cats and the password is password" 
echo ""
echo "You can finish installation of your OpenCATS applicant tracking system at: http://localhost/opencats"
