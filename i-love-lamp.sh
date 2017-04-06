LAMP Stack Set Up Tool

read -p "First Run? (y/n) " RESP; if [ "$RESP" = "y" ]; then 
#First System Updates
yum -y update
#Get/Compile Apache 
yum -y install autoconf libtool openssl-devel pcre-devel
cd /usr/local/src
curl -O -L https://github.com/apache/httpd/archive/2.4.25.tar.gz
curl -O -L https://github.com/apache/apr/archive/1.5.2.tar.gz
curl -O -L https://github.com/apache/apr-util/archive/1.5.4.tar.gz
tar -zxf 2.4.25.tar.gz
tar -zxf 1.5.2.tar.gz
tar -zxf 1.5.4.tar.gz
cp -r apr-1.5.2 httpd-2.4.25/srclib/apr
cp -r apr-util-1.5.4 httpd-2.4.25/srclib/apr-util
cd httpd-2.4.25
./buildconf
./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2
make
make install


systemctl start httpd.service
systemctl enable httpd.service
#Set Up Firewall for traffic
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
#Creating Dirs for Vhosts and Enabling 
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf

#Installing MariaDB
yum -y install mariadb-server mariadb
systemctl start mariadb
mysql_secure_installation
systemctl enable mariadb.service

#Installing PHP
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php71

yum -y install php php-mysql php-cli php-common php-devel php-gd
systemctl restart httpd.service

#Setup/Complie SuPHP
yum -y groupinstall 'Development Tools'
cd /usr/local/src
wget http://suphp.org/download/suphp-0.7.2.tar.gz
tar zxvf suphp-0.7.2.tar.gz
wget -O suphp.patch https://lists.marsching.com/pipermail/suphp/attachments/20130520/74f3ac02/attachment.patch
patch -Np1 -d suphp-0.7.2 < suphp.patch
cd suphp-0.7.2
autoreconf -if
./configure --prefix=/usr/ --sysconfdir=/etc/ --with-apr=/usr/bin/apr-1-config --with-apache-user=apache --with-setid-mode=owner --with-logfile=/var/log/httpd/suphp_log
make
make install
touch /etc/httpd/conf.d/suphp.conf
echo "suPHP_Engine off" >> /etc/httpd/conf.d/suphp.conf
echo "LoadModule suphp_module modules/mod_suphp.so" >> /etc/httpd/conf.d/suphp.conf
touch /etc/suphp.conf
echo "SUPHP.CONF" >> /etc/suphp.conf
systemctl restart httpd.service

### End First Install Loop ###


### Start Domain Setup Loop ###

#Making Our Domains
read -p "Set Up Domain? (y/n) " RESP; if [ "$RESP" = "y" ]; then 
#Gather Infos
echo -n "Domain: "; read input_domain
echo -n "User: "; read input_user; 
echo -n "IP: "; read input_ip; 

#Make User
adduser ${input_user} 
passwd ${input_user}
mkdir -p /home/${input_user}/public_html
chown -R${input_user}:${input_user} /home/${input_user}/${input_domain}/public_html

#SSL?
mkdir -p /var/ssl
openssl req -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

#Make and Fill .conf
touch /etc/httpd/sites-available/${input_domain}.conf
echo "HTTPD DATA HERE" >> /etc/httpd/sites-available/${input_domain}.conf
ln -s /etc/httpd/sites-available/${input_domain}.conf /etc/httpd/sites-enabl
ed/${input_domain}.conf
systemctl restart httpd.service

### End Domain Setup Loop ###
