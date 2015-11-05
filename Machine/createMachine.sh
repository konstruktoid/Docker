#!/bin/sh
# https://github.com/docker/machine
# https://www.digitalocean.com/

INPUT="$1"
ACCESSTOKEN="$2"
LOCATION="$3"

MACHINE="/usr/local/bin/docker-machine"
MACHINERELEASE="https://github.com/docker/machine/releases/download/v0.5.0/docker-machine_linux-amd64.zip"
HARDENING="https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh"


if ! test -d "$TMP"; then
   TMP=/tmp
fi

if [ "$INPUT" = "install" ]; then
   cd $TMP &&
   curl -L $MACHINERELEASE > machine.zip && \
   unzip machine.zip && \
   rm machine.zip && \
   sudo mv -f docker-machine* /usr/local/bin
   sudo chown root:root /usr/local/bin/docker-machine*
   sudo chmod 0755 /usr/local/bin/docker-machine*
   /usr/local/bin/docker-machine -v
   exit
fi

if [ -z "$ACCESSTOKEN" ]; then
   echo "ACCESSTOKEN required"
   exit
fi

if ! test -x "$MACHINE"; then
  echo "docker-machine doesn't seem to be installed."
fi

if [ -z "$INPUT" ]; then
   echo "Machine name required"
   exit 1
  else
   docker-machine create --driver digitalocean --digitalocean-access-token "$ACCESSTOKEN" --digitalocean-region "$LOCATION" "$INPUT"
   docker-machine ssh "$INPUT" "wget -O /tmp/baselineDockerHost.sh $HARDENING; /bin/bash /tmp/baselineDockerHost.sh"
fi
