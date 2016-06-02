#!/bin/sh
VERSION='2'
BASENAME='cass'
NODES=10
SEED=0

if docker ps | grep -q "$BASENAME$SEED"; then
  echo "Cassandra seed container $BASENAME$SEED already exists."
else
  docker run --name "$BASENAME$SEED" -h "$BASENAME$SEED" -d cassandra:$VERSION
fi

nloop=1
while [ $nloop -lt $NODES ]; do
  if docker ps | grep -q "cass$nloop"; then
    echo "Container cass$nloop already exists."
  else
    docker run --name "$BASENAME$nloop" -h "$BASENAME$nloop" -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' $BASENAME$SEED)" "cassandra:$VERSION"
  fi
  nloop=$((nloop + 1))
done

echo
for info in $(docker ps | grep "$BASENAME" | awk '{print $1}'); do
  docker inspect --format='{{ .Name }} - {{ .NetworkSettings.IPAddress }} - {{ .Id }}' "$info"
done

echo
ncnt=$(( NODES - 1 ))
echo "Cheat sheet:"
echo "docker exec -ti $BASENAME\$(shuf -i 0-$ncnt -n 1) bash"
