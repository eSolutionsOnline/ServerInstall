#!/bin/bash
###### core.sh
appname=$2
user=$1

echo "Update Package List & System Packages"
apt-get update
apt-get -y upgrade

echo "Install Some PPAs"
apt-get install -y software-properties-common curl
apt-add-repository ppa:chris-lea/redis-server -y
apt-get update

echo "Install Some Basic Packages"
apt-get install build-essential git libmcrypt4 libpcre3-dev ntp unzip supervisor ufw curl git-core git-flow nodejs redis-server memcached beanstalkd ntpdate
 
echo "Set My Timezone"
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ntpdate -s ntp.ubuntu.com
dpkg-reconfigure tzdata
ntpdate -s ntp.ubuntu.com

echo "Configure Beanstalkd"
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start

echo "Configure Supervisor"
systemctl enable supervisor.service
service supervisor start

echo ""
echo ""
echo ""
