#!/bin/bash

LOG=/tmp/myrpi.log
PWD=`pwd`
cd /var/myrpi/myrpi/scripts

function fn_exit_ok {
	echo "------------------------------------------------------------"
	fn_log_echo "MyRPi installer finished"
	exit 0
}

function fn_exit_error {
	echo "------------------------------------------------------------"
	fn_log_echo "MyRPi installer FAILED - view log in $LOG"
	exit 1
}

function fn_log_echo {
	echo $1
	echo `date +"%Y-%m-%d %T"` $1 >> $LOG
}

ISSUE=`cat /etc/issue`

clear
echo "" > $LOG
echo "------------------------------------------------------------"
fn_log_echo "MyRPi installer started"

# detect Linux distro version
SCRIPT=0
if [[ $ISSUE =~ Debian.*(([0-9]+)\.[0-9]+) ]]; then
	# [1] version number e.g. 6.0 [2] => major version number e.g. 6
	if [ "${BASH_REMATCH[2]}" = "6" ]; then
		SCRIPT='debian_squeeze.sh'
	fi
fi

if [ $SCRIPT = 0 ]; then
	fn_log_echo "Could not detect Linux version in $ISSUE"
	fn_exit_error
fi

fn_log_echo "Using $SCRIPT for $ISSUE"

./$SCRIPT $LOG

if [ "$?" != "0" ]; then
	fn_exit_error
else
	fn_exit_ok
fi

