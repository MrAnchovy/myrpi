#!/bin/bash

## Set up the context
##
ME=`whoami`
WWW_USER=www-data:www-data
TEMPLATES_PATH=/var/myrpi/myrpi/templates

## Disable any existing hosts
##
sudo rm /etc/nginx/sites-enabled/*

## Copy the vhost templates into place and link the correct one
##
sudo cp $TEMPLATES_PATH/sites-available/* /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/default-php-fpm /etc/nginx/sites-enabled/default-php-fpm

## Create the vhost directory and make the user own it
##
sudo mkdir -p /var/hosts/default
sudo chown $ME:$ME /var/hosts
sudo chown $ME:$ME /var/hosts/default

## Create directories for application logs, file storage and cache and make the
## web server process own them so they are writeable by web scripts
##
mkdir -p /var/hosts/default/log
sudo chown $WWW_USER /var/hosts/default/log
mkdir -p /var/hosts/default/var
sudo chown $WWW_USER /var/hosts/default/var
mkdir -p /var/hosts/default/tmp
sudo chown $WWW_USER /var/hosts/default/tmp

## Create the public html directory and populate it with demo files. This will
## be owned by the current user so will not be writeable by web scripts.
##
mkdir -p /var/hosts/default/public_html
cp $TEMPLATES_PATH/public_html/* /var/hosts/default/public_html

sudo nginx -s reload

exit 0
