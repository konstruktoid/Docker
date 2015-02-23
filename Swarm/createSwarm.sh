#!/bin/bash
# https://github.com/docker/machine
# https://github.com/docker/swarm
# https://www.digitalocean.com/

ORIGIN="hivemind"
MASTER="kerrigan"
NODES="baneling zergling hydralisk"

ACCESSTOKEN=""
REGION="ams3"

if ! test -d "$TMP";
	then
		TMP=/tmp
fi

if [ -z $ACCESSTOKEN ];
	then
		echo "ACCESSTOKEN required"
		exit
fi

if [ -z "$ORIGIN" ] || [ -z "$MASTER" ] || [ -z "$NODES" ];
	then
		echo "Swarm machine names need to be set up"
		exit
	else
		docker-machine create --driver digitalocean --digitalocean-access-token $ACCESSTOKEN --digitalocean-region $REGION $ORIGIN
		$(docker-machine env $ORIGIN)

		docker run swarm create 1> $TMP/swarm
		SWARMTOKEN=`cat $TMP/swarm`

		docker-machine create --swarm --swarm-master --swarm-discovery token://`echo $SWARMTOKEN` --driver digitalocean --digitalocean-access-token $ACCESSTOKEN --digitalocean-region $REGION $MASTER 

		for node in $NODES;
 			do
				docker-machine create --swarm  --swarm-discovery token://`echo $SWARMTOKEN` --driver digitalocean --digitalocean-access-token $ACCESSTOKEN --digitalocean-region $REGION $node
			done
fi
