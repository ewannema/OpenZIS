# Installing OpenZis on CentOS 6.5 #

This is a list of what I did to get OpenZis installed on CentOS 6.5. This is  
not guaranteed to be 100% correct since I do not have familiarity with the  
code base. I am continuing to test.

### Configuration Variables ###
- server name = openzis.localdomain
- mysql username = openzis
- mysql password = education

## Basic Package Installation ##

1. Start with a base CentOS install
2. yum update
3. Install VMware tools
    1. yum install http://packages.vmware.com/tools/esx/5.1/repos/vmware-tools-repo-RHEL6-9.0.0-2.x86_64.rpm
    2. yum install vmware-tools-esx-kmods vmware-tools-esx-nox
4. Install and Configure MySQL
    1. yum install mysql mysql-server
    2. chkconfig --levels 2345 mysqld on
    3. service mysqld start
    4. mysql_secure_installation
5. Install and Configure Apache and PHP dependencies
    1. yum install httpd php php-gd php-devel php-pear php-mysql php-xml
    2. chkconfig --levels 2345 httpd on
    3. service httpd start
6. Install and Configure the Application
    1. yum install git
    2. My github fork has some db fixes so I will pull from there.
       1. cd /var/www
       2. git clone https://github.com/ewannema/OpenZIS.git
       3. chown -R apache:apache OpenZIS
    3. cd OpenZIS/OpenZIS
    4. cp config.me.ini config.ini
    5. Edit config.ini. The following had to be updated for my installation.
        - host = openzis.localdomain
        - password = "education"
        - password2 = "education"
        - application.root.directory = /var/www/OpenZIS
    6. Make some essential directories that are not part of the repository.
        1. cd /var/www/OpenZIS
        2. mkdir logs tmp
        3. chown apache:apache logs tmp
    7. Create the database and application user.
        1. mysql -u root -peducation
        2. CREATE DATABASE openzis;
        3. CREATE USER 'openzis' IDENTIFIED BY 'education';
        4. GRANT all on openzis.* to 'openzis';
        5. FLUSH PRIVILEGES;
        6. exit
        7. mysql openzis -u root -peducation < OpenZIS/db/mysql/ZISDB.sql
        8. mysql openzis -u root -peducation < OpenZIS/db/mysql/update.sql
        9. mysql openzis -u root -peducation < OpenZIS/db/mysql/update_uk1.sql
        10. mysql openzis -u root -peducation < OpenZIS/db/mysql/events.sql
        11. mysql openzis -u root -peducation < OpenZIS/db/mysql/filters.sql
        13. mysql openzis -u root -peducation < OpenZIS/db/mysql/specs/sif_au_11.sql
        14. mysql openzis -u root -peducation < OpenZIS/db/mysql/specs/sif_uk_13.sql
        15. mysql openzis -u root -peducation < OpenZIS/db/mysql/specs/sif_us_24.sql
        16. mysql openzis -u root -peducation < OpenZIS/db/mysql/specs/sif_us_25.sql
    8. Update the admin and zis URLs
        1. mysql openzis -u openzis -peducation
        2. UPDATE zit_server set ADMIN_URL='http://openzis.localdomain/admin';
        3. UPDATE zit_server set ZIT_URL='http://openzis.localdomain/zis';
        4. exit
    9. Configure Apache to Serve the Application
        1. Add the following to /etc/httpd/conf.d/openzis.conf
```
<VirtualHost *:80>
  ServerName openzis.localdomain
  DocumentRoot /var/www/OpenZIS/OpenZIS/
  Alias /admin /var/www/OpenZIS/OpenZIS/ADMIN_SERVER
  Alias /zis /var/www/OpenZIS/OpenZIS/ZIT_SERVER

  <Directory /var/www/OpenZIS/OpenZIS/ADMIN_SERVER>
    AllowOverride All
    Options Indexes FollowSymlinks
  </Directory>

  <Directory /var/www/OpenZIS/OpenZIS/ZIT_SERVER>
    AllowOverride All
    Options Indexes FollowSymlinks
  </Directory>
</VirtualHost>
```
	     2. service httpd restart
        2. Configure Directory Override Files
            1. cd /var/www/OpenZIS/OpenZIS/ZIT_SERVER
            2. mv htaccess.txt .htaccess
            3. cd /var/www/OpenZIS/OpenZIS/ADMIN_SERVER
            4. mv htaccess.txt .htaccess
        3. Allow HTTP through the firewall
            1. iptables -I INPUT 5 -m state --state NEW -p TCP --dport 80 -j ACCEPT
        4. Allow httpd to connect to the database if using selinux
            1. setsebool -P httpd_can_network_connect_db 1



## Troubleshooting ##
- Review any 500 errors in /var/log/httpd/error_log
- If imported data objects are not showing up correctly, remove the Zend cach at /var/www/OpenZIS/tmp/* and restart httpd
