#!/bin/bash

USERIP="$(w -ih | awk '{print $3}' | head -n1)"

if [[ "$USERIP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  ADMINIP="$USERIP"
else
  ADMINIP=""
fi

cd /var/tmp || exit 1
git clone https://github.com/konstruktoid/hardening.git
cd hardening || exit 1

sed -i "s/FW_ADMIN='/FW_ADMIN='$ADMINIP /" ./ubuntu.cfg
sed -i "s/SSH_GRPS='/SSH_GRPS='$(id -nG) /" ./ubuntu.cfg
sed -i "s/CHANGEME=''/CHANGEME='$(date +%s)'/" ./ubuntu.cfg
