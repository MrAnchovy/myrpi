#!/bin/bash

ME=`whoami`
PWD=`pwd`
ARG1=$1
ARG2=$2

echo "------------------------------------------------------------"
echo "Cleaning up any old download and preparing for a new one"
echo "[ARG1][$ARG2]"

sudo rm -rf /var/myrpi
sudo mkdir /var/myrpi
sudo chown $ME /var/myrpi
cd /var/myrpi

echo "------------------------------------------------------------"
echo "Downloading installation script

wget --no-check-certificate -q https://github.com/MrAnchovy/myrpi/tarball/master

echo "------------------------------------------------------------"
echo "Extracting installation script
echo "------------------------------------------------------------"

tar -xzvf master

if [[ "`ls`" =~ (MrAnchovy-myrpi-[A-Za-z0-9_-]*) ]]; then
	mv "${BASH_REMATCH[1]}" myrpi

	cd myrpi
	./install.sh
	cd $PWD
else
	echo "Error in download - please try again"
fi
