#!/bin/bash
# https://github.com/docker/machine
# https://www.digitalocean.com/

ACCESSTOKEN=""
LOCATION="ams2"

MACHINE="/usr/local/bin/docker-machine"
MACHINERELEASE="https://github.com/docker/machine/releases/download/v0.4.1/docker-machine_linux-amd64"
HARDENING="https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh"

INPUT="$@"

if ! test -d "$TMP";
  then
    TMP=/tmp
fi

if [ "$INPUT" == "upgrade" ];
  then
    cd $TMP && wget -nv $MACHINERELEASE
    sudo mv $TMP/docker-machine_linux-amd64 /usr/local/bin/
    sudo chown root:root /usr/local/bin/docker-machine_linux-amd64
    sudo chmod 0755 /usr/local/bin/docker-machine_linux-amd64
    sudo ln -vfs /usr/local/bin/docker-machine_linux-amd64 "$MACHINE"
    docker-machine -v
    exit
fi

if [ -z $ACCESSTOKEN ];
  then
    echo "ACCESSTOKEN required"
    exit
fi

if ! test -x "$MACHINE";
  then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 
    sudo apt-get update && sudo apt-get -y upgrade
    sudo apt-get install lxc-docker
    sudo addgroup "$(whoami)" docker
    cd $TMP && wget -nv $MACHINERELEASE
    sudo mv $TMP/docker-machine_linux-amd64 /usr/local/bin/
    sudo chown root:root /usr/local/bin/docker-machine_linux-amd64
    sudo chmod 0755 /usr/local/bin/docker-machine_linux-amd64
    sudo ln -vfs /usr/local/bin/docker-machine_linux-amd64 "$MACHINE"
    docker-machine -v
fi

if [ -z "$INPUT" ];
  then
    echo "Machine name required"
    exit
  else
    docker-machine create --driver digitalocean --digitalocean-access-token $ACCESSTOKEN --digitalocean-region "$LOCATION" "$@"
    docker-machine ssh "$@" "wget -O /tmp/baselineDockerHost.sh $HARDENING; /bin/bash /tmp/baselineDockerHost.sh"
fi
