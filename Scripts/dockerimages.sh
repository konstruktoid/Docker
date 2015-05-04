#!/bin/bash

IMAGES="alpine:latest tianon/ubuntu-core:latest ubuntu:latest centos:latest debian:latest fedora:latest busybox:latest oraclelinux:latest"

date > docker_images_result

for base in $IMAGES;
  do
    image=`echo $base | sed -e 's/\//_/g' -e 's/:/_/g'`
    docker pull $base
    docker save -o $image.tar $base
    du -h $image.tar >> docker_images_result
    rm $image.tar
  done

if test -e ./ubuntu-core-15.04-beta2-core-amd64.tar.gz;
  then
    cat ./ubuntu-core-15.04-beta2-core-amd64.tar.gz | sudo docker import - ubuntubeta2:latest
    docker save -o ubuntubeta2.tar ubuntubeta2:latest
    du -h ubuntubeta2.tar >> docker_images_result
    rm ubuntubeta2.tar
  else
    echo "ubuntu-core-15.04-beta2-core-amd64.tar.gz not found"
fi
