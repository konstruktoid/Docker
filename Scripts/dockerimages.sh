#!/bin/sh

IMAGES="
  alpine:3.3
  alpine:3.4
  alpine:edge
  alpine:latest
  busybox:latest
  centos:6
  centos:6.8
  centos:7
  centos:latest
  debian:7
  debian:8
  debian:latest
  fedora:23
  fedora:24
  fedora:latest
  konstruktoid/alpine:latest
  konstruktoid/debian:7
  konstruktoid/debian:8
  konstruktoid/debian:latest
  konstruktoid/nginx:latest
  konstruktoid/ubuntu:14.04
  konstruktoid/ubuntu:16.04
  konstruktoid/ubuntu:16.10
  konstruktoid/ubuntu:latest
  nginx:latest
  nginx:mainline-alpine
  nginx:stable-alpine
  opensuse:13.1
  opensuse:13.2
  opensuse:latest
  oraclelinux:5
  oraclelinux:6
  oraclelinux:7
  oraclelinux:latest
  ubuntu:14.04.5
  ubuntu:16.04
  ubuntu:16.10
  ubuntu:latest
"

date > docker_images_result
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
