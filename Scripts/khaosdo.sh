#!/bin/sh
# push the Docker environments to failure

numContainers=$(docker ps -q | wc -l)

if [ "$numContainers" -eq 0 ]; then
  echo "No containers running. Shutting down."
  exit 1
fi

randShuf=$(shuf -i 1-5 -n 1)
shufContainer=$(docker ps -q | shuf -n 1 | awk '{print $1}')
shufContainerCmd="$(docker help | awk '{print $1}' | grep -E 'kill|restart|stop' |\
  shuf -n 1)"
containerImage=$(docker inspect -f '{{.Config.Image}}' "$shufContainer")
containerName=$(docker inspect -f '{{.Name}}' "$shufContainer")

containerCMD() {
  containerInfo="$shufContainer ($containerName): $containerImage"
  khaosMsg="Executing $shufContainerCmd on container $containerInfo"
  logger -i -t "khaosdo" -p "user.info" "$khaosMsg"
  docker "$shufContainerCmd" "$shufContainer"
}

serverCMD() {
  echo "restarting the Docker daemon"
  systemctl restart docker.service
}

if [ "$randShuf" -le 3 ]; then
  containerCMD
else
  serverCMD
fi
