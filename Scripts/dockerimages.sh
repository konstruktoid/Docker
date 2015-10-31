#!/bin/sh

IMAGES="
  alpine:latest
  alpine:3.2
  alpine:3.1
  alpine:2.7
  alpine:2.6
  busybox:latest
  centos:7
  centos:6.6
  centos:6
  centos:5
  centos:latest
  debian:latest
  debian:8
  debian:7
  debian:6
  fedora:22
  fedora:21
  fedora:20
  fedora:latest
  konstruktoid/alpine:latest
  konstruktoid/debian:jessie
  konstruktoid/debian:wheezy
  konstruktoid/ubuntu:trusty
  konstruktoid/ubuntu:wily
  opensuse:13.1
  opensuse:13.2
  opensuse:latest
  oraclelinux:7
  oraclelinux:6
  oraclelinux:5
  oraclelinux:latest
  ubuntu:latest
  ubuntu:15.10
  ubuntu:14.10
  ubuntu:14.04
"

UBUNTUCORE="http://cdimage.ubuntu.com/ubuntu-core/daily/current/wily-core-amd64.tar.gz"

date > docker_images_result

for base in $IMAGES;
  do
    image=$(echo "$base" | sed -e 's/\//_/g' -e 's/:/_/g')
    docker pull "$base"
    docker save -o "$image.tar" "$base"
    du -h "$image.tar" >> docker_images_result
    rm "$image.tar"
  done

if [ -n "$UBUNTUCORE" ];
  then
    docker import "$UBUNTUCORE" ubuntucore:latest
    docker save -o ubuntucore.tar ubuntucore:latest
    du -h ubuntucore.tar >> docker_images_result
    rm ubuntucore.tar
fi
