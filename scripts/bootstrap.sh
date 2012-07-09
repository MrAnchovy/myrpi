#!/bin/bash

ME=`whoami`

sudo rm -rf /var/myrpi
sudo mkdir /var/myrpi
sudo chown $ME /var/myrpi
cd /var/myrpi
wget --no-check-certificate -q https://github.com/MrAnchovy/myrpi/tarball/master
tar -xzvf master

if [[ "`ls`" =~ (MrAnchovy-myrpi-[A-Za-z0-9_-]*) ]]; then
	mv "${BASH_REMATCH[1]}" myrpi
	cd myrpi
	./install.sh
else
	echo "Error in download - please try again"
fi
