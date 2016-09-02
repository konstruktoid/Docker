#!/bin/sh

IMAGES="
  alpine:2.6
  alpine:2.7
  alpine:3.1
  alpine:3.2
  alpine:3.3
  alpine:latest
  busybox:latest
  centos:5
  centos:6
  centos:6.6
  centos:7
  centos:latest
  debian:6
  debian:7
  debian:8
  debian:latest
  fedora:20
  fedora:21
  fedora:22
  fedora:23
  fedora:24
  fedora:latest
  konstruktoid/alpine:latest
  konstruktoid/debian:7
  konstruktoid/debian:8
  konstruktoid/debian:latest
  konstruktoid/ubuntu:latest
  konstruktoid/ubuntu:14.04
  konstruktoid/ubuntu:14.10
  konstruktoid/ubuntu:15.10
  konstruktoid/ubuntu:16.04
  konstruktoid/ubuntu:16.10
  opensuse:13.1
  opensuse:13.2
  opensuse:latest
  oraclelinux:5
  oraclelinux:6
  oraclelinux:7
  oraclelinux:latest
  ubuntu:14.04
  ubuntu:14.10
  ubuntu:15.10
  ubuntu:16.04
  ubuntu:16.10
  ubuntu:latest
  nginx:latest
  nginx:mainline-alpine
  nginx:stable-alpine
  konstruktoid/nginx:latest
"

date > docker_images_result

for base in $IMAGES;
  do
    image=$(echo "$base" | sed -e 's/\//_/g' -e 's/:/_/g')
    docker pull "$base"
    docker save -o "$image.tar" "$base"
    du -h "$image.tar" >> docker_images_result
    rm "$image.tar"
  done
