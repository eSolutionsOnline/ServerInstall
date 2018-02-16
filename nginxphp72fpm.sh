#!/bin/bash
###### nginxphp72fpm.sh
appname=$2
user=$1

echo "Update Package List & System Packages"
apt-get update
apt-get -y upgrade

echo "Install Some PPAs"
apt-add-repository ppa:ondrej/php -y
apt-get update

echo "Install Some Basic Packages"
apt-get install -y nginx php7.2-cli php7.2-dev php7.2-mysql php7.2-curl php7.2-memcached php7.2-imap php7.2-mbstring php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap php7.2-intl php7.2-readline php-xdebug php7.2-fpm  

echo "Install Composer"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "Add Composer Global Bin To Path"
printf "\nPATH=\"$(sudo su - $user -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a /home/$user/.profile

echo "Set Some PHP CLI Settings"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini

echo "Install Nginx & PHP-FPM"
rm /etc/nginx/sites-enabled/default 2> /dev/null
rm /etc/nginx/sites-available/default 2> /dev/null

cat > /etc/nginx/sites-enabled/default << EOF
server {
    listen 80 default_server;
    server_name $appname;
    set \$siteroot "/home/$user/$appname/";
    set \$webfolder "web";
    client_max_body_size 20m;
    access_log  /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;
    location /assets/ {
        root \$siteroot\$webfolder;
    }
    location / {
        root \$siteroot\$webfolder;
        index index.php;
        if (-f \$request_filename){
            break;
        }
        rewrite ^(.*)\$ /index.php last;
    }
    location ~ \.php {
        root \$siteroot\$webfolder;
        fastcgi_split_path_info ^(.+\.php)(.*)\$;
        fastcgi_pass   unix:/run/php/php7.2-fpm.sock;
        fastcgi_param  SCRIPT_FILENAME  \$siteroot\$webfolder\$fastcgi_script_name;
        fastcgi_param  PATH_INFO \$fastcgi_path_info;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    location ~ /\.ht {
        deny  all;
    }
}
EOF

cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;
    server_name $appname;
    set \$siteroot "/home/$user/$appname/";
    set \$webfolder "web";
    client_max_body_size 20m;
    access_log  /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;
    location /assets/ {
        root \$siteroot\$webfolder;
    }
    location / {
        root \$siteroot\$webfolder;
        index index.php;
        if (-f \$request_filename){
            break;
        }
        rewrite ^(.*)\$ /index.php last;
    }
    location ~ \.php {
        root \$siteroot\$webfolder;
        fastcgi_split_path_info ^(.+\.php)(.*)\$;
        fastcgi_pass   unix:/run/php/php7.2-fpm.sock;
        fastcgi_param  SCRIPT_FILENAME  \$siteroot\$webfolder\$fastcgi_script_name;
        fastcgi_param  PATH_INFO \$fastcgi_path_info;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    location ~ /\.ht {
        deny  all;
    }
}
EOF

echo "Setup Some PHP-FPM Options"
echo "xdebug.remote_enable = 1" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.2/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/7.2/mods-available/opcache.ini
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/7.2/fpm/php.ini
echo -e "\e[1m\e[5m\033[31m!!!WARINING!!!\e[0m\e[25m\e[21m"
read -p "Would you like to set this server up in DEV mode? [y/N]? "
if [[ $REPLY = [yY] ]]; then
   sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/fpm/php.ini
fi
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.2/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.2/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini

echo "Disable XDebug On The CLI"
phpdismod -s cli xdebug

echo "Copy fastcgi_params to Nginx because they broke it on the PPA"
cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param QUERY_STRING \$query_string;
fastcgi_param REQUEST_METHOD \$request_method;
fastcgi_param CONTENT_TYPE \$content_type;
fastcgi_param CONTENT_LENGTH \$content_length;
fastcgi_param SCRIPT_FILENAME \$request_filename;
fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
fastcgi_param REQUEST_URI \$request_uri;
fastcgi_param DOCUMENT_URI \$document_uri;
fastcgi_param DOCUMENT_ROOT \$document_root;
fastcgi_param SERVER_PROTOCOL \$server_protocol;
fastcgi_param GATEWAY_INTERFACE CGI/1.1;
fastcgi_param SERVER_SOFTWARE nginx/\$nginx_version;
fastcgi_param REMOTE_ADDR \$remote_addr;
fastcgi_param REMOTE_PORT \$remote_port;
fastcgi_param SERVER_ADDR \$server_addr;
fastcgi_param SERVER_PORT \$server_port;
fastcgi_param SERVER_NAME \$server_name;
fastcgi_param HTTPS \$https if_not_empty;
fastcgi_param REDIRECT_STATUS 200;
EOF

echo "Set The Nginx & PHP-FPM User"
sed -i "s/user www-data;/user $user;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sed -i "s/user = www-data/user = $user/" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = $user/" /etc/php/7.2/fpm/pool.d/www.conf

sed -i "s/listen\.owner.*/listen.owner = $user/" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = $user/" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.2/fpm/pool.d/www.conf

echo "Configure $user to run nginx"
usermod -a -G www-data $user
id $user
groups $user

######## THIS IS NOT WORKING!!!!! #######
# Install Node
#/usr/bin/npm install -g gulp
#/usr/bin/npm install -g bower
#/usr/bin/npm install -g yarn
#/usr/bin/npm install -g grunt-cli
######## THIS IS NOT WORKING!!!!! #######

echo "Restarting PHP7.2 FPM"
/etc/init.d/php7.2-fpm restart
 
echo "Restarting NGINX"
/etc/init.d/nginx restart

echo ""
echo ""
echo ""
