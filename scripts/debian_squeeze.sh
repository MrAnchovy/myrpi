#!/bin/bash

LOG=$1

# UTILITY FUNCTIONS ===========================================================

function fn_log_echo {
	echo $1
	echo `date +"%Y-%m-%d %T"` $1 >> $LOG
}

function fn_append {
	echo $1 | sudo tee -a $2 > /dev/null
}

function fn_apt_add_key {
	wget -O - -q $1 | sudo apt-key add -
}

function fn_apt_add_source {
	fn_append "\n$1\n" /etc/apt/sources.list
}

# MAIN FUNCTIONS ==============================================================

function fn_apt_update {
	echo "------------------------------------------------------------"
	fn_log_echo "Updating repository"
	SUCCESS=0; TRIES=3
	while [ $TRIES -gt 0 ]; do

		sudo apt-get update 2>> $LOG

		RESULT="$?"
		if [ "$RESULT" = "0" ]; then
			TRIES=0
		else
			TRIES-=1
		fi
	done

	if [ "$RESULT" != "0" ]; then
		fn_log_echo "FAILED: apt-get update failed too many times - exiting"
		exit 1
	fi
}

function fn_nginx_check {
	if [[ `whereis nginx` =~ /usr/sbin/nginx ]]; then
		NGINX_IS_INSTALLED=1
	else
		NGINX_IS_INSTALLED=0
	fi
}

function fn_nginx_install {

	fn_log_echo "Installing nginx"

	sudo apt-get install nginx 2>> LOG

	if [ "$?" != "0" ]; then
		fn_log_echo "FAILED: could not install nginx - exiting"
		exit 1
	fi

}

function fn_nginx_reinstall {

	fn_log_echo "Re-installing nginx"

	sudo apt-get install --reinstall nginx 2>> LOG

	if [ "$?" != "0" ]; then
		fn_log_echo "FAILED: could not re-install nginx - exiting"
		exit 1
	fi

}


function fn_nginx_conf {
	echo
}

function fn_nginx_vhost {

	## disable any existing default vhosts
	sudo rm /etc/nginx/sites-enabled/default*

	## copy the vhost templates into place and link the correct one
	sudo cp ../templates/default-no-php /etc/nginx/sites-available
	sudo cp ../templates/default-php /etc/nginx/sites-available
	sudo ln -s /etc/nginx/sites-available/default-no-php /etc/nginx/sites-enabled/default-no-php

	#sudo chown root:root local-default

	sudo mkdir -p /var/www/default/public_html
	sudo mkdir -p /var/www/default/log

	sudo nginx -s reload
}

function fn_php_check {
	if [[ `whereis php` =~ /usr/bin/php ]]; then
		PHP_IS_INSTALLED=1
	else
		PHP_IS_INSTALLED=0
	fi
}

function fn_php_install {

	fn_log_echo "Installing PHP"

	sudo apt-get install php5-cgi 2>> LOG

	if [ "$?" != "0" ]; then
		fn_log_echo "FAILED: could not install PHP - exiting"
		exit 1
	fi

}

function fn_php_reinstall {

	fn_log_echo "Re-installing PHP"

	sudo apt-get install --reinstall php5-cgi 2>> LOG

	if [ "$?" != "0" ]; then
		fn_log_echo "FAILED: could not re-install PHP - exiting"
		exit 1
	fi

}


function fn_php_conf {
	echo
}

function fn_php_fcgi {
	
	## disable any existing default vhosts
	sudo rm /etc/nginx/sites-enabled/default*

	## copy the vhost templates into place and link the correct one
	sudo cp ../templates/default-php /etc/nginx/sites-available
	sudo ln -s /etc/nginx/sites-available/default-php /etc/nginx/sites-enabled/default-php

	sudo nginx -s reload

	sudo cp ../templates/php-fastcgi /etc/init.d/php-fastcgi
	# make it executable
	sudo chmod +x /etc/init.d/php-fastcgi
	# start it now
	sudo invoke-rc.d php-fastcgi start
	# and finally make it permanent
	sudo insserv php-fastcgi
}








function mysql_install() {

	echo    "------------------------------------------------------------"
	echo    "Installing php5"

	sudo apt-get install mysql-server mysql-client 

	if [ "$?" != "0" ]; then
		echo "------------------------------------------------------------"
		echo "FAILED: could not install php5 - exiting"
		exit 1
	fi
}

function mysql_conf {
	echo
}



function fn_http_index {
	CONTENT="<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Raspberry Pi (TM) web server</title>
</head>

<body>
<h1>Raspberry Pi (TM) web server</h1>
<p>Installed and ready to go. Visit
<a href="http://www.myrpi.net">myrpi.net</a> for more.
</p>
</body>
</html>
"

	## create a new vhost file, move it into place and link it
	echo "$CONTENT" > index.html
	mv index.html /var/www/default/public_html
	sudo ln -sf /etc/nginx/sites-available/local-default /etc/nginx/sites-enabled/local-default

}


# CODE STARTS HERE ============================================================

PHP_IS_INSTALLED=0
MYSQL_IS_INSTALLED=0
PHPMYADMIN_IS_INSTALLED=0


# Update repository ===========================================================

fn_apt_update


# Deal with nginx =============================================================

NGINX_IS_INSTALLED=0

fn_nginx_check

if [ "$NGINX_IS_INSTALLED" = 1 ]; then
	echo "------------------------------------------------------------"
	echo -n "Do you want to re-install the nginx web server (enter Y to re-install) ? "
	read ANSWER
	if [[ "$ANSWER" =~ [yY]+ ]]; then
		fn_nginx_reinstall
		fn_nginx_conf
		fn_nginx_vhost
		fn_log_echo "nginx re-install complete"
	else
		fn_log_echo "nginx re-install skipped"
	fi
else
	echo "------------------------------------------------------------"
	fn_nginx_install
	fn_nginx_conf
	fn_nginx_vhost
	NGINX_IS_INSTALLED=1
	fn_log_echo "nginx install complete"
fi


# Deal with PHP   =============================================================

PHP_IS_INSTALLED=0

fn_php_check

if [ "$PHP_IS_INSTALLED" = 1 ]; then
	echo "------------------------------------------------------------"
	echo -n "Do you want to re-install PHP (enter Y to re-install) ? "
	read ANSWER
	if [[ "$ANSWER" =~ [yY]+ ]]; then
		fn_php_reinstall
		fn_php_conf
		fn_php_fcgi
		fn_log_echo "PHP re-install complete"
	else
		fn_log_echo "PHP re-install skipped"
	fi
else
	echo "------------------------------------------------------------"
	fn_php_install
	fn_php_conf
	fn_php_fcgi
	PHP_IS_INSTALLED=1
	fn_log_echo "PHP install complete"
fi


# End =========================================================================

exit 0

























echo -n "Do you want to install N"
read name
echo -n "Enter your gender and press [ENTER]: "
read -n 1 gender
echo

grep -i "$name" "$friends"
# UPDATE=1
UPDATE=0
# NGINX=1
NGINX=install
HTML=install
PHP=install
MYSQL="install auto" 
MYSQLSTART=1
PHPMYADMIN=install
PHPMYADMIN_PORT=
PHPMYADMIN_DIR="phpmyadmin"
PEAR=install

## change to home directory
cd /home/pi
if [ ! -d rpinet ]; then
  mkdir rpinet
fi
cd rpinet



if [ "$NGINX" != "0" ]; then
	fn_nginx_install
	fn_nginx_conf
	fn_nginx_vhost
	# restart nginx
	sudo nginx
fi
if [ "$HTTP_INDEX" != "0" ]; then
	fn_http_index
fi
if [ "$PHP" != "0" ]; then
	fn_php_install
fi

