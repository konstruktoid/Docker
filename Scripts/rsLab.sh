#!/bin/sh

CNAME='mongo'
RSNAME='labRS'
NETNAME='dbNet'
CIMAGE='konstruktoid/mongodb'
NUMSERVERS=5

INCR=0

    #"$SERVERNAME.$NETNAME" \

if ! docker network ls | grep "$NETNAME"; then
  docker network create --attachable --internal "$NETNAME"
fi

while [ $INCR -lt $NUMSERVERS ]; do
  INCR=$((INCR + 1))
  SERVERNAME="$CNAME$INCR"

  echo "Creating $SERVERNAME."
  docker run \
    --cap-drop=all --cap-add=setgid --cap-add=setuid \
    --name "$SERVERNAME" \
    --hostname "$SERVERNAME" \
    --network "$NETNAME" \
    --detach \
    "$CIMAGE" \
    --replSet "$RSNAME" \
    --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem \
    --bind_ip_all
done

echo 'Creating replica set:'
sleep 5
docker exec -ti "$SERVERNAME" mongo --ssl --sslAllowInvalidCertificates --eval 'printjson(rs.initiate())'

echo 'Adding nodes:'
for n in $(docker inspect --format '{{ .Name }}' $(docker ps -q) | grep mongo | grep -v 'mongo5' | tr -d '/'); do
  docker exec -ti "$SERVERNAME" mongo --ssl --sslAllowInvalidCertificates --eval "rs.add(\"$n\")"
done

echo 'Replica set status: '
docker exec -ti "$SERVERNAME" mongo --ssl --sslAllowInvalidCertificates --eval 'printjson(rs.status())'

echo
echo 'Cheat sheet:'
echo "docker exec -ti $SERVERNAME mongo --ssl --sslAllowInvalidCertificates"
