#!/bin/bash
# wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/install.sh && chmod 0777 install.sh && ./install.sh

svrversion=ubuntu-16.04-server-amd64
user=$USER
install_source="/home/$user/install/"
appversion=""
appsource=""

echo '.___                 __         .__  .__      _________            .__        __   '
echo '|   | ____   _______/  |______  |  | |  |    /   _____/ ___________|__|______/  |_ '
echo '|   |/    \ /  ___/\   __\__  \ |  | |  |    \_____  \_/ ___\_  __ \  \____ \   __\'
echo '|   |   |  \\___ \  |  |  / __ \|  |_|  |__  /        \  \___|  | \/  |  |_> >  |  '
echo '|___|___|  /____  > |__| (____  /____/____/ /_______  /\___  >__|  |__|   __/|__|  '
echo '         \/     \/            \/                    \/     \/         |__|         '
echo "V1.0.0"
echo ""
echo ""

read -p "What is the name of the application? "
if [[ ! $REPLY ]]; then
    echo "You must choose an application name to install"
    echo "Goodbye"
    echo ""
    echo ""
    exit 1
fi

appname=$REPLY

echo "What version would you like to install:"
echo "[1] Nginx, PHP7.1 FPM, MySQL"
echo "[2] Nginx, PHP7.2 FPM, MySQL"
echo "[3] Nginx, PHP7.2 FPM, PostGres"
#echo "[4] Nginx, PHP7.3 FPM, MySQL (Development)"
read -p "Default Option [1] "
case $REPLY in
    2)
        echo "You have chosen Nginx, PHP7.2 FPM, MySQL"
        appversion="Nginx, PHP7.2 FPM, MySQL"
        appsource="nginxmysqlphp72fpm.sh"
        ;;
    3)
        echo "You have chosen Nginx, PHP7.3 FPM, PostGres"
        appversion="Nginx, PHP7.3 FPM, PostGres"
        appsource="nginxpostgresphp72fpm.sh"
        ;;
    *)
        echo "You have chosen Nginx, PHP7.1 FPM, MySQL"
        appversion="Nginx, PHP7.1 FPM, MySQL"
        appsource="nginxmysqlphp71fpm.sh"
        ;;
esac

echo ""
echo ""
echo -e "Server Version:\t\t$svrversion"
echo -e "User:\t\t\t$user"
echo -e "Application Name:\t$appname"
echo -e "Application Config:\t$appversion"
echo ""
read -p "Are the details above correct? [y/N]? "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "You have choosen to stop"
    echo "Goodbye"
    echo ""
    echo ""
    exit 1
fi
echo ""
echo ""

echo -e "\e[1m\e[5m\033[31m!!!WARINING!!!\e[0m\e[25m\e[21m"

echo -e "This script will now download what is needed then execute them \e[1mall files will be removed after the install \e[21m "
echo -e " \e[0m "

read -p "Would you like to continue? [y/N]? "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "You have choosen to stop"
    echo "Goodbye"
    echo ""
    echo ""
    exit 1
fi



mkdir install
wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/core.sh -O install/core.sh
wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/$appsource -O install/app.sh
wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/security.sh -O install/security.sh
wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/userconfig.sh -O install/userconfig.sh
wget https://raw.githubusercontent.com/eSolutionsOnline/ServerInstall/master/cleanup.sh -O install/cleanup.sh
chmod -R 0777 install

mkdir -p /home/$user/$appname/web/
cat > /home/$user/$appname/web/index.php << EOF
<?php phpinfo(); ?>
EOF
ls
sudo bash $install_source"core.sh" "$user" "$appname"
echo ""
echo ""
sudo bash $install_source"app.sh" "$user" "$appname"
echo ""
echo ""
bash $install_source"userconfig.sh" "$user" "$appname"
echo ""
echo ""
sudo bash $install_source"security.sh" "$user" "$appname"
echo ""
echo ""
sudo bash $install_source"cleanup.sh" "$user" "$appname"
echo ""
echo ""

rm -R install
rm $0

echo "All scripts have been executed and removed"
echo ""
echo ""

echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
echo "It is recomended that you reboot the server now for all changes to take effect"
echo ""
