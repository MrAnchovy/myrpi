<?php

error_reporting(-1);
ini_set('display_errors', 1);

date_default_timezone_set('Europe/London');

echo "<pre>\n";
echo `cat /proc/cpuinfo`;
echo "</pre>\n";

// test SQLite
$dbfile = '/var/hosts/default/var/sqlite/' . md5(microtime());
$db = new PDO("sqlite:$dbfile");

$rs = $db->query('create table test ( value )');

if ( $rs===FALSE ) {
  print_r($db->errorInfo());
} else {
  echo 'SQLite OK';
}

unlink($dbfile);

phpinfo();

