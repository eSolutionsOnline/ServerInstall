#!/bin/bash
###### security.sh
appname=$2
user=$1

echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
echo "If you have not added a public key then you will not be able to use SSH"
read -p "Would secure the SSH config? [Y/n]? "
if [[ ! $REPLY =~ ^[nN]$ ]]; then

    echo "Updating the SSH security"
    sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config
    sed -i "s/UsePAM.*/UsePAM no/" /etc/ssh/sshd_config
    sed -i "s/PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config

fi

echo "Firewall config"
ufw enable
ufw default deny
ufw allow 80
ufw allow 443

echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
read -p "Would disable the firewall? [Y/n]? "
if [[ ! $REPLY =~ ^[nN]$ ]]; then
    echo "Disable the firewall"
    ufw disable

fi

