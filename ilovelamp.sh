echo "LAMP Stack Set Up Tool v0.1";

# APACHE - https://blacksaildivision.com/how-to-install-apache-on-centos
# PHP - http://php.net/manual/en/install.unix.apache2.php
# SUPHP - https://www.howtoforge.com/tutorial/install-suphp-on-centos-7/
# MARIADB - https://mariadb.com/kb/en/mariadb/generic-build-instructions/

### Start First Run Loop ###
read -p "First Run? (y/n) " RESP; if [ "$RESP" = "y" ]; then 
#First System Updates
yum -y update;
#Pre-install Tools
wget -q http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm -ivh epel-release-7-9.noarch.rpm

yum -y groupinstall 'Development Tools';
yum -y install autoconf libtool openssl-devel pcre-devel yum-utils nano which cmake;
yum -y install git gcc gcc-c++ libxml2-devel pkgconfig bzip2-devel curl-devel libcurl-devel 
libxml2-devel libpng-devel libjpeg-devel libXpm-devel freetype-devel gmp-devel libmcrypt-devel 
libicu-devel libaio-devel mariadb-devel recode-devel autoconf bison re2c bzip2-devel aspell-devel jemalloc-devel
yum-builddep -y mariadb;

#APACHE
cd /usr/local/src;
curl -s -O -L https://github.com/apache/httpd/archive/2.4.25.tar.gz;
curl -s -O -L https://github.com/apache/apr/archive/1.5.2.tar.gz;
curl -s -O -L https://github.com/apache/apr-util/archive/1.5.4.tar.gz;
tar -zxf 2.4.25.tar.gz;
tar -zxf 1.5.2.tar.gz;
tar -zxf 1.5.4.tar.gz;
cp -r apr-1.5.2 httpd-2.4.25/srclib/apr;
cp -r apr-util-1.5.4 httpd-2.4.25/srclib/apr-util;
cd httpd-2.4.25;
./buildconf;
./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2;
make;
make install;
#APACHE CONF
rm -f /usr/local/apache2/conf/httpd.conf
cp -a templates/httpd.conf /usr/local/apache2/conf/httpd.conf
mkdir -p /usr/local/apache2/conf/sites-available;
mkdir -p /usr/local/apache2/conf/sites-enabled;
mkdir -p /usr/local/apache2/conf/ssl;
#APACHE USER
groupadd www
useradd httpd -g www --no-create-home --shell /sbin/nologin
#APACHE START
echo "pathmunge /usr/local/apache2/bin" > /etc/profile.d/httpd.sh
cp -a templates/httpd.service /etc/systemd/system/httpd.service
systemctl start httpd.service;
systemctl enable httpd.service;
#FIREWALL - NO FIREWALL YET
#
#PHP
cd /usr/local/src;
curl -s -O -L https://github.com/php/php-src/archive/php-7.1.3.tar.gz;
tar -zxf php-7.1.3.tar.gz;
cd php-src-php-7.1.3;
./buildconf --force
./configure --prefix=/usr/local/php7 --with-apxs2=/usr/local/apache2/bin/apxs --with-xpm-dir=/usr --with-config-file-path=/usr/local/php7/etc --with-config-file-scan-dir=/usr/local/php7/etc/conf.d --enable-bcmath --with-bz2 --with-curl --enable-filter --enable-fpm --with-gd --enable-gd-native-ttf --with-freetype-dir --with-jpeg-dir --with-png-dir --enable-mbstring --with-mcrypt --enable-mysqlnd --with-mysql-sock=/var/lib/mysql/mysql.sock --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite --disable-phpdbg --disable-phpdbg-webhelper --with-openssl --with-sqlite3 --enable-zip --with-zlib;
make;
make install;
#PHP CONF
cp ./php.ini-production /usr/local/php7/lib/php.ini;
cp ./sapi/fpm/www.conf /usr/local/php7/etc/php-fpm.d/www.conf;
cp ./sapi/fpm/php-fpm.conf /usr/local/php7/etc/php-fpm.conf;
systemctl restart httpd.service;
#SUPHP
cd /usr/local/src;
wget -q http://suphp.org/download/suphp-0.7.2.tar.gz;
tar -zxf suphp-0.7.2.tar.gz;
wget -q -O suphp.patch https://lists.marsching.com/pipermail/suphp/attachments/20130520/74f3ac02/attachment.patch;
patch -Np1 -d suphp-0.7.2 < suphp.patch;
cd suphp-0.7.2;
autoreconf -if;
./configure --prefix=/usr/ --sysconfdir=/etc/ --with-apr=/usr/local/apache2/bin/apr-1-config --with-apxs=/usr/local/apache2/bin/apxs --with-apache-user=httpd --with-setid-mode=owner --with-logfile=/usr/local/apache2/log/suphp.logmake;
make;
make install;
#SUPHP CONF
touch /usr/local/apache2/conf/suphp.conf;
echo "suPHP_Engine off" >> /usr/local/apache2/conf/suphp.conf;
echo "LoadModule suphp_module modules/mod_suphp.so" >> /usr/local/apache2/conf/suphp.conf;
cp -a templates/suphp.conf /etc/suphp.conf;
systemctl restart httpd.service;
#MARIADB
cd /usr/local/src;
curl -s -O -L https://github.com/MariaDB/server/archive/mariadb-10.1.22.tar.gz; 
tar -zxf mariadb-10.1.22.tar.gz; 
cd server-mariadb-10.1.22;
#cmake . -DBUILD_CONFIG=mysql_release;
cmake . -DBUILD_CONFIG=mysql_release -DWITH_JEMALLOC=yes;
make;
make install;
useradd mysql -g www --no-create-home --shell /sbin/nologin;
chown -R mysql /usr/local/mysql/;
scripts/mysql_install_db --user=mysql;
/usr/local/mysql/bin/mysqld_safe --user=mysql;

cp -a templates/mariadb.service /etc/systemd/system/mariadb.service
systemctl start mariadb.service;
systemctl enable mariadb.service;

### Start Domain Setup Loop ###
#Making Our Domains
read -p "Set Up Domain? (y/n) " RESP; if [ "$RESP" = "y" ]; then 
#Gather Infos
echo -n "Domain: "; read input_domain; 
echo -n "User: "; read input_user; 
echo -n "IP: "; read input_ip; 

#Make User
adduser ${input_user};
passwd ${input_user};
mkdir -p /home/${input_user}/public_html;
chown -R${input_user}:${input_user} /home/${input_user}/${input_domain}/public_html;

#SSL?
#mkdir -p /var/ssl
#openssl req -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

#Make and Fill .conf
touch /etc/httpd/sites-available/${input_domain}.conf;
cat example.com.conf | sed -e "s/input_domain/${input_domain}/" | sed -e "s/input_user/${input_user}/" | sed -e "s/input_ip/${input_ip}/" >> /etc/httpd/sites-available/${input_domain}.conf; 
ln -s /usr/local/apache2/conf/sites-available/${input_domain}.conf /usr/local/apache2/conf/sites-enabled/${input_domain}.conf;
systemctl restart httpd.service;
fi;
### End Domain Setup Loop ###
fi
### End First Run Loop ###
