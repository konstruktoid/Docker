#!/bin/sh

IMAGES="
  alpine:3.3
  alpine:3.4
  alpine:3.5
  alpine:3.6
  alpine:3.7
  alpine:3.8
  alpine:edge
  alpine:latest
  busybox:latest
  centos:6
  centos:6.8
  centos:7
  centos:latest
  debian:7
  debian:8
  debian:9
  debian:9-slim
  debian:latest
  fedora:23
  fedora:24
  fedora:25
  fedora:26
  fedora:27
  fedora:28
  fedora:latest
  konstruktoid/alpine:latest
  konstruktoid/debian:7
  konstruktoid/debian:8
  konstruktoid/debian:9
  konstruktoid/debian:latest
  konstruktoid/nginx:latest
  konstruktoid/ubuntu:14.04
  konstruktoid/ubuntu:16.04
  konstruktoid/ubuntu:16.10
  konstruktoid/ubuntu:17.04
  konstruktoid/ubuntu:18.04
  konstruktoid/ubuntu:latest
  nginx:latest
  nginx:mainline-alpine
  nginx:stable-alpine
  opensuse:13.2
  opensuse:42.2
  opensuse:latest
  oraclelinux:5
  oraclelinux:6
  oraclelinux:7
  oraclelinux:latest
  ubuntu:14.04.5
  ubuntu:16.04
  ubuntu:16.10
  ubuntu:17.04
  ubuntu:17.10
  ubuntu:18.04
  ubuntu:18.10
  ubuntu:latest
"

LANG=C date -u > docker_images_result
IMGTMP="$(mktemp)"

for base in $IMAGES;
  do
    image=$(echo "$base" | sed -e 's/\//_/g' -e 's/:/_/g')
    docker pull "$base"
    docker save -o "$image.tar" "$base"
    du -h "$image.tar" >> "$IMGTMP"
    rm "$image.tar"
  done

sort -k1 -n "$IMGTMP" >> docker_images_result
rm "$IMGTMP"

docker run --rm --read-only --tmpfs /tmp:rw,nosuid,nodev -v /var/run/docker.sock:/var/run/docker.sock konstruktoid/docker-garby
