#! /bin/bash

sudo service mysql stop
sudo service memcached stop
kill $(ps aux | awk '/[b]eanstalkd/ {print $2}')
