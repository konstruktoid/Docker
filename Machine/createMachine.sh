#!/bin/bash
# https://github.com/docker/machine
# https://www.digitalocean.com/

MACHINE="/usr/local/bin/docker-machine"
MACHINERELEASE="https://github.com/docker/machine/releases/download/v0.1.0-rc4/docker-machine_linux-amd64"
ACCESSTOKEN=""

if ! test -x "$MACHINE";
	then
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
		sudo apt-get update && sudo apt-get -y upgrade 
		sudo apt-get install lxc-docker
		sudo addgroup `whoami` docker
		wget $MACHINERELEASE
		sudo mv docker-machine_linux-amd64 /usr/local/bin/
		sudo chown root:root /usr/local/bin/docker-machine_linux-amd64
		sudo ln -vfs /usr/local/bin/docker-machine_linux-amd64 "$MACHINE"
		docker-machine -v
fi

INPUT="$@"
if [ -z $INPUT ];
        then
                echo "Machine name required"
        else
                docker-machine create --driver digitalocean --digitalocean-access-token $ACCESSTOKEN --digitalocean-region ams2 $@
                docker-machine ssh $@
fi