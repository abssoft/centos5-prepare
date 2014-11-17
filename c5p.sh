#!/bin/sh

#ssh welcome message
/bin/uname --kernel-name --nodename --kernel-release --kernel-version --machine > /etc/motd


echo 'LANG="en_US.UTF-8"' >> /etc/sysconfig/i18n
echo 'SYSFONT="latarcyrheb-sun16"' >> /etc/sysconfig/i18n

#----upgrade php to 5.4 see http://www.servermom.org/upgrade-php-53-54-55-centos/1534/

cd /usr/src
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh epel-release-6*.rpm
rpm -Uvh remi-release-6*.rpm 
sed -i '1,6s/^enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo

yum -y groupinstall "Development Tools"
yum -y install libtool-ltdl-devel openssl-devel openssl mod_ssl pcre-devel gcc make gcc-c++ rpm-build rpm-devel autoconf automake lynx ncurses
yum -y install mysql-devel mysql-server php-mysqli httpd-devel php-devel php-common php-gd php-mcrypt php-xml php-xmlrpc php-domxml php-mbstring php-pear

yum -y install git npm
npm install -g bower
npm install -g preen

yum update -y


#---------apc begin-------------
printf "\n" | pecl install apc
printf "extension = apc.so\napc.enabled=1" > /etc/php.d/apc.ini
service httpd restart
#-----------apc end-------------

#----------- memcache begin----------
yum -y install memcached
/etc/init.d/memcached start
chkconfig memcached on
printf "\n" | pecl install  memcache
printf "extension=memcache.so" > /etc/php.d/memcache.ini

#----------- memcache end ----------

service httpd restart

#----------sphinx begin--------------
cd /usr/src

wget http://sphinxsearch.com/files/sphinx-2.1.9-release.tar.gz
tar xzf sphinx-2.1.9-release.tar.gz 
cd sphinx-2.1.9-release

./configure --prefix=/usr/local/sphinx
make && make install

#/usr/local/sphinx/etc
# add config

#---- add sphinx cronjobs

printf "\n@reboot /usr/local/sphinx/bin/searchd --config /usr/local/sphinx/etc/sphinx.conf" >> /var/spool/cron/root

printf "\n1 */12 * * *  /usr/bin/pgrep indexer || time /usr/local/sphinx/bin/indexer --all --rotate --config /usr/local/sphinx/etc/sphinx.conf" >> /var/spool/cron/root

#--------------sphinx end------------------


#------------nginx------------------

To add nginx yum repository, create a file named /etc/yum.repos.d/nginx.repo and paste one of the configurations below:

CentOS:

printf "[nginx]\nname=nginx repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=0\nenabled=1" > /etc/yum.repos.d/nginx.repo

#-------------nginx end--------------------


#------unoconv begin---------------------
#http://debianworld.ru/articles/unoconv-konvertaciya-word-pdf-swf-html-ppt-dokumentov-v-debian-ubuntu/
#aptitude install openoffice.org-headless openoffice.org-writer openoffice.org-impress
#aptitude install unoconv
#unoconv --listener &
#todo make it be in /etc/init.d
#------unoconv end-----------------------

#---Imagick---

yum -y install ImageMagick ImageMagick-devel ImageMagick-perl
printf "\n" | pecl install imagick
echo "extension=imagick.so" >> /etc/php.d/imagick.ini
#----------------------

#-----datetime sync-----
yum -y install ntp
ntpdate pool.ntp.org
service ntpd start
chkconfig ntpd on


#---xpdf----
yum -y install libpng-devel
cd /usr/src
wget ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-linux-3.04.tar.gz
tar xzf xpdfbin-linux-3.04.tar.gz
cp -u xpdfbin-linux-3.04/bin64/* /usr/local/bin/
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-cyrillic.tar.gz
tar xzf xpdf-cyrillic.tar.gz
mkdir -p /usr/local/share/xpdf/cyrillic
cp -u xpdf-cyrillic/* /usr/local/share/xpdf/cyrillic/
cp -u xpdf-cyrillic/add-to-xpdfrc /usr/local/etc/xpdfrc

#Antiword
cd /usr/src
wget http://www.winfield.demon.nl/linux/antiword-0.37.tar.gz
tar xzf antiword-0.37.tar.gz
cd antiword-0.37
make all && make global_install

cd ~
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
