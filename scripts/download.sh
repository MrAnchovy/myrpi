#!/bin/bash

ME=`whoami`
PWD=`pwd`

echo "------------------------------------------------------------"
echo "Cleaning up any old download and preparing for a new one"

## Remove completely any previous download
sudo rm -rf /var/myrpi

## Create directory for download, give it to me and switch to it
sudo mkdir /var/myrpi
sudo chown $ME /var/myrpi
cd /var/myrpi

echo "------------------------------------------------------------"
echo "Downloading MyRPi.net installation package"

wget --no-check-certificate https://github.com/MrAnchovy/myrpi/tarball/master

echo "------------------------------------------------------------"
echo "Extracting MyRPi.net installation package"
echo "------------------------------------------------------------"

## Unpack downlaod
tar -xzvf master

## Check download package exists
if [[ "`ls`" =~ (MrAnchovy-myrpi-[A-Za-z0-9_-]*) ]]; then
	## Rename download package (contains version number)
	mv "${BASH_REMATCH[1]}" myrpi

	## make all scripts executable
	chmod +x myrpi/scripts/*
	exit 0

else
	echo "Error in download - please try again"
	exit 1
fi
