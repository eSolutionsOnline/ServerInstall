#!/bin/bash
###### mysql.sh
appname=$2
user=$1

echo "MySQL stuff"
echo "Update Package List & System Packages"
apt-get update
apt-get -y upgrade

echo "Install Some Basic Packages"

echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
read -p "During the MySQL install you will be asked for a password for the root user please use 'password' [press any key to continue] "
apt-get install php7.2-mysql mysql-client mysql-server

##!!!NOT USED YET!!!#
##mysql_secure_installation

echo "Setting bind address"
sed -i "s/bind-address.*/#bind-address = 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf

echo "Creating test database"
mysql -uroot -ppassword -e "CREATE DATABASE $appname; USE $appname; CREATE TABLE $appname (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, appname VARCHAR(30) NOT NULL, user VARCHAR(30) NOT NULL); INSERT INTO $appname (appname, user) VALUES ('$appname', '$user');"


echo "Generate password"
newpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)

echo ""
echo ""
echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
echo "Your new password is"
echo "root: $newpass"
echo "$user: $newpass"
echo ""
read -p "[press any key to continue] "
echo ""
echo ""

mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO '$user'@'localhost' IDENTIFIED BY '$newpass';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$newpass';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$newpass';"

echo "Updating Test page"
cat > /home/$user/$appname/web/index.php << EOF
<?php 
\$db = new PDO('mysql:host=localhost;dbname=$appname;charset=utf8mb4', '$user', '$newpass');
\$query = \$db->query("SELECT * FROM $appname");
\$result = \$query->fetchAll(PDO::FETCH_ASSOC)
?>

<h1>Data from the DB</h1>
<pre><?php print_r(\$result) ?></pre>

<?php phpinfo() ?>
EOF

echo "restarting MySQL"
/etc/init.d/mysql restart
