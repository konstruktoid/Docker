#!/bin/bash
for conf in `ls -1 /etc/mongod/*.conf`; 
	do
		sudo -u mongodb mongod --config $conf
		sleep 5
	done 
