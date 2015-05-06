#!/bin/bash

IMAGES="alpine:latest tianon/ubuntu-core:latest ubuntu:latest ubuntu:vivid centos:latest centos:6 debian:latest debian:wheezy fedora:20 fedora:latest busybox:latest oraclelinux:latest"
UBUNTUCORE="http://cdimage.ubuntu.com/ubuntu-core/daily/current/vivid-core-amd64.tar.gz"

date > docker_images_result

for base in $IMAGES;
  do
    image=`echo $base | sed -e 's/\//_/g' -e 's/:/_/g'`
    docker pull $base
    docker save -o $image.tar $base
    du -h $image.tar >> docker_images_result
    rm $image.tar
  done

if [ -n "$UBUNTUCORE" ];
  then
    docker import $UBUNTUCORE ubuntucore:latest
    docker save -o ubuntucore.tar ubuntucore:latest
    du -h ubuntucore.tar >> docker_images_result
    rm ubuntucore.tar
fi
