#!/bin/sh
# This script will install a new OpenCATS instance on a fresh CentOS 7 server.
# This script is experimental and does not ensure any security.


export DEBIAN_FRONTEND=noninteractive
yum update
yum -y install mariadb-server mariadb wget
systemctl start mariadb.service
systemctl enable mariadb.service
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum update
yum install -y php56w php56w-soap php56w-ldap php56w-gd php56w-mysql
systemctl restart httpd.service


# Set up database
mysql -u root --execute="CREATE DATABASE cats_dev;"
mysql -u root --execute="CREATE USER 'cats'@'localhost' IDENTIFIED BY 'password';"
mysql -u root --execute="GRANT ALL PRIVILEGES ON cats_dev.* TO 'cats'@'localhost';"


# Download OpenCATS
cd /var/www/html
wget https://github.com/opencats/OpenCATS/releases/download/0.9.4/opencats-0.9.4-full.zip
unzip opencats-0.9.4-full.zip
mv /var/www/html/home/travis/build/opencats/OpenCATS opencats
rm -Rf /var/www/html/home /var/www/html/opencats/INSTALL_BLOCK


# Set file and folder permissions
chown apache:apache -R opencats
cd /var/www/html/opencats
find . -type f -exec chmod 0644 {} \;
find . -type d -exec chmod 0770 {} \;
chcon -t httpd_sys_content_t /var/www/html/opencats -R
chcon -t httpd_sys_rw_content_t /var/www/html/opencats -R


# Install resume indexing tools

wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/Kenzy:/modified:/C7/CentOS_7/x86_64/antiword-0.37-20.1.x86_64.rpm
rpm -ivh antiword-0.37-20.1.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/h/html2text-1.3.2a-14.el7.x86_64.rpm
rpm -ivh html2text-1.3.2a-14.el7.x86_64.rpm
yum install -y poppler poppler-utils unrtf
rm antiword-0.37-20.1.x86_64.rpm html2text-1.3.2a-14.el7.x86_64.rpm
systemctl restart httpd.service

echo ""
echo "Setup Finished, Your OpenCATS applicant tracking system should now be installed."
echo "MySQL was installed without a root password, It is recommended that you set a root MySQL password."
echo ""

echo "You can finish installation of your OpenCATS applicant tracking system at: http://localhost/opencats"
