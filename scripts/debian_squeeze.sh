#!/bin/bash

LOG=$1

function fn_log_echo {
	echo $1
	echo `date +"%Y-%m-%d %T"` $1 >> $LOG
}

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

function fn_append {
	echo $1 | sudo tee -a $2 > /dev/null
}

function fn_apt_add_key {
	wget -O - -q $1 | sudo apt-key add -
}

function fn_apt_add_source {
	fn_append "\n$1\n" /etc/apt/sources.list
}


function fn_php_install() {

	echo    "------------------------------------------------------------"
	echo    "Installing php5"

	INSTALL="php5-fpm"
	sudo apt-get install $INSTALL

	INSTALL="php5-cgi"
	INSTALL="$INSTALL php5-mysql php5-curl php5-gd php5-idn php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl"
	INSTALL="$INSTALL php-pear"
	sudo apt-get install $INSTALL

	if [ "$?" != "0" ]; then
		echo "------------------------------------------------------------"
		echo "FAILED: could not install php5 - exiting"
		exit 1
	fi
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

function fn_nginx_conf {
	echo
}

function fn_nginx_vhost {

	## create the PHP part of the script, commenting it out if not needed
	if [ "$PHP" != "0" ]; then

		PHP_TEXT="
	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	#{if php}
	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index index.php;
		fastcgi_param  SCRIPT_FILENAME  /var/www\$fastcgi_script_name;
		include fastcgi_params;
	}"
	#{endif php}

	else
		PHP_TEXT="
	#{if php}
	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	# location ~ \.php$ {
	#	try_files \$uri =404;
	#	fastcgi_pass 127.0.0.1:9000;
	#	fastcgi_index index.php;
	#	fastcgi_param  SCRIPT_FILENAME  /var/www\$fastcgi_script_name;
	#	include fastcgi_params;
	# }"
	#{endif php}

	
	fi

	CONTENT="
server {
        listen   80; ## listen for ipv4; this line is default and implied
        # {{listen   [::]:80 default ipv6only=on; ## listen for ipv6}}

	# Make site accessible from http://localhost/
        server_name localhost;

	location / {
                root        /var/www/default/public_html;
	        access_log  /var/www/default/log/access.log;
	        error_log   /var/www/default/log/error.log;

		# First attempt to serve request as file, then
                # as directory, then fall back to index.html
                try_files $uri $uri/ /index.html /index.php /index.htm;
        }

	# error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
        #
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/www;
        }

	$PHP_TEXT

	# deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
                deny all;
        }
}"

	## disable the existing default vhost
	if [ -f /etc/nginx/sites-available/default ]; then
		sudo unlink /etc/nginx/sites-available/default
	fi

	## create a new vhost file, move it into place and link it
	echo "$CONTENT" > local-default
	sudo chown root:root local-default
	sudo mv local-default /etc/nginx/sites-available/
	sudo ln -sf /etc/nginx/sites-available/local-default /etc/nginx/sites-enabled/local-default
	mkdir -p /var/www/default/public_html
	mkdir -p /var/www/default/log
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
	echo -n "Do you want to re-install NGINX (enter Y to re-install) ? "
	read ANSWER
	if [ "$ANSWER" = "Y" ]; then
		fn_nginx_reinstall
	else
		fn_log_echo "nginx re-install skipped"
	fi
else
	fn_nginx_install
fi

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

