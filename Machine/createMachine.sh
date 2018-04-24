#!/bin/sh
# https://github.com/docker/machine
# https://www.digitalocean.com/

INPUT="$1"
ACCESSTOKEN="$2"
LOCATION="$3"

MACHINE="/usr/local/bin/docker-machine"
MACHINERELEASE="docker-machine-$(uname -s)-$(uname -m)"
MACHINEURL="https://github.com/docker/machine/releases/download/v0.14.0/$MACHINERELEASE"
HARDENING="https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh"


if [ "$MACHINERELEASE" = "docker-machine-Darwin-x86_64" ]; then
  SHA256SUM="5e3b34c038cf42e9e4c6bcf841ef6fe19827ebb5a90687a8c157235c9104b240"
elif [ "$MACHINERELEASE" = "docker-machine-Linux-aarch64" ]; then
  SHA256SUM="0f94312bbb9637fe9c3616700d35c8a6562a640bdff4e46e1a3a7c9698890a76"
elif [ "$MACHINERELEASE" = "docker-machine-Linux-armhf" ]; then
  SHA256SUM="cc3b4ea12eaf39cee1c604898c536ac9570f2cddab98ac204bc7844d0175b522"
else
  SHA256SUM="a4c69bffb78d3cfe103b89dae61c3ea11cc2d1a91c4ff86e630c9ae88244db02"
fi

if ! test -d "$TMP"; then
  TMP=/tmp
fi

if [ "$INPUT" = "install" ]; then
  echo "Downloading $MACHINEURL."
  curl -sSL "$MACHINEURL" > "$TMP/machine"
  if [ "$(openssl sha1 -sha256 $TMP/machine | awk '{print $NF}')" != "$SHA256SUM" ]; then
    echo "SHA256 mismatch. Exiting."
    exit 1
  else
    echo "SHA256 OK."
  fi

  sudo mv $TMP/machine $MACHINE
  sudo chown root:root $MACHINE*
  sudo chmod 0755 $MACHINE*
  $MACHINE -v
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
