#!/usr/bin/env bash

DIR='/etc/docker/certs.d'

ID=$(id -u)
if [ "x$ID" != "x0" ]; then
  echo "root privileges required."
  exit 1
fi

if ! test -d "$DIR"; then
  mkdir -p "$DIR"
fi

FQDN="$(hostname --long)"
HOST="$(hostname --short)"

CAKEY="$DIR/ca-$HOST-key.pem"
CACRT="$DIR/ca-$HOST.pem"
SERVERKEY="$DIR/server-$HOST-key.pem"
SERVERCSR="$DIR/server-$HOST.csr"
SERVEREXT="$DIR/server-$HOST-extfile.cnf"
SERVERCRT="$DIR/server-$HOST-cert.pem"
CLIENTKEY="$DIR/client-$HOST-key.pem"
CLIENTCSR="$DIR/client-$HOST.csr"
CLIENTEXT="$DIR/client-$HOST-extfile.cnf"
CLIENTCRT="$DIR/client-$HOST-cert.pem"

openssl genrsa -out "$CAKEY" 4096
openssl req -new -x509 -days 365 -key "$CAKEY" -sha256 -subj "/CN=$FQDN" -out "$CACRT"

openssl genrsa -out "$SERVERKEY" 4096
openssl req -new -subj "/CN=$FQDN" -key "$SERVERKEY" -out "$SERVERCSR"

iparr=()
for i in $(ifconfig  | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'); do
  iparr+=("$i")
done

ip=$(echo "${iparr[@]}" | sed 's/[[:space:]]/,IP:/g')

echo "subjectAltName = IP:$ip" > "$SERVEREXT"

openssl x509 -req -extfile "$SERVEREXT" -days 365 -in "$SERVERCSR" -CA "$CACRT" \
  -CAkey "$CAKEY" -CAcreateserial -out "$SERVERCRT"

openssl genrsa -out "$CLIENTKEY" 4096
openssl req -subj "/CN=$HOST-client" -new -key "$CLIENTKEY" -out "$CLIENTCSR"

echo "extendedKeyUsage = clientAuth" > "$CLIENTEXT"

openssl x509 -req -days 365 -in "$CLIENTCSR" -CA "$CACRT" -CAkey "$CAKEY" \
  -CAcreateserial -out "$CLIENTCRT" -extfile "$CLIENTEXT"

rm $DIR/*.csr
chmod 0444 $DIR/*.pem
chmod 0400 $DIR/server*key.pem $DIR/ca*key.pem

SETTINGS="
DOCKER DAEMON SETTINGS:
docker daemon --tlsverify --tlscacert=$CACRT --tlscert=$SERVERCRT --tlskey=$SERVERKEY -H=0.0.0.0:2376

DOCKER CLIENT SETTINGS:
docker --tlsverify --tlscacert=$CACRT --tlscert=$CLIENTCRT --tlskey=$CLIENTKEY -H=$FQDN:2376 version

DOCUMENTATION:
https://docs.docker.com/articles/https/"

printf "%b\n" "$SETTINGS\n"
