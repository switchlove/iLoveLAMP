# iLoveLAMP
Quick and dirty bash lamp stack setup

PLEASE NOTE: THIS SCRIPT IS A WORK IN PROGRESS, IT WILL NOT WORK 

Usage:
- sh ./ilovelamp.sh

Currently Installs the following:
- httpd v2.4.25
- apr v1.5.2 (required for Apache)
- apr-util v1.5.4(required for Apache)
- mariadb v5.5.52
- mariadb-server v5.5.52
- php71-php v7.1.3 
- php71-php-devel v7.1.3
- php71-php-cli v7.1.3
- php71-php-common v7.1.3
- php71-php-mysqlnd v7.1.3
- php71-php-gd v7.1.3

To Do:
- Auto setup of domains
- Auto configuration of vhosts
- Add exim service setup for Email
- Add named service for DNS
