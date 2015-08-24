#!/bin/sh

CNAME='mongo'
RSNAME='labRS'
NETNAME='dbNet'
CIMAGE='konstruktoid/mongodb'
NUMSERVERS=5

INCR=0

while [ $INCR -lt $NUMSERVERS ]; do
  INCR=$((INCR + 1))
  SERVERNAME="$CNAME$INCR"

  docker run \
    --cap-drop=all --cap-add=setgid --cap-add=setuid \
    --name "$SERVERNAME" \
    --hostname "$SERVERNAME" \
    --publish-service="$SERVERNAME.$NETNAME" \
    --detach \
    "$CIMAGE" \
    --replSet "$RSNAME" \
    --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
done

echo
echo "docker exec -ti $SERVERNAME mongo --ssl --sslAllowInvalidCertificates"
