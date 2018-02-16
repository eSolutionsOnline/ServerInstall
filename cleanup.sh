#!/bin/bash
###### cleanup.sh
appname=$2
user=$1

echo "Clean Up"
apt-get -y autoremove
apt-get -y clean

echo "Enable Swap Memory"
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

echo "Minimize The Disk Image"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

echo ""
echo ""
echo ""
