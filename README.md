# iLoveLAMP
Quick and dirty bash lamp stack setup

PLEASE NOTE: THIS SCRIPT IS A WORK IN PROGRESS, IT WILL NOT WORK 

Usage:
- git clone https://github.com/switchlove/iLoveLAMP.git
- sh ./ilovelamp.sh

Currently Installs the following:
- httpd v2.4.25
- apr v1.5.2 (required for Apache)
- apr-util v1.5.4(required for Apache)
- php v7.1.3 
- suphp v0.7.2
- mariadb v10.1.22
- mariadb-server v10.1.22

To Do:
- Setup IPTables
- Auto setup of domains
- Auto configuration of vhosts
- Add exim service setup for Email
- Add named service for DNS
