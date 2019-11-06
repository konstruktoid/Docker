#!/bin/sh

IMAGES="
  alpine:3.6
  alpine:3.7
  alpine:3.8
  alpine:3.9
  alpine:3.10
  alpine:edge
  alpine:latest
  busybox:1.31
  busybox:latest
  centos:6
  centos:7
  centos:8
  centos:latest
  debian:7
  debian:8
  debian:8-slim
  debian:9
  debian:9-slim
  debian:10
  debian:10-slim
  debian:latest
  fedora:26
  fedora:27
  fedora:28
  fedora:29
  fedora:30
  fedora:latest
  konstruktoid/alpine:latest
  konstruktoid/debian:7
  konstruktoid/debian:8
  konstruktoid/debian:9
  konstruktoid/debian:buster
  konstruktoid/debian:latest
  konstruktoid/nginx:latest
  konstruktoid/ubuntu:14.04
  konstruktoid/ubuntu:16.04
  konstruktoid/ubuntu:16.10
  konstruktoid/ubuntu:17.04
  konstruktoid/ubuntu:18.04
  konstruktoid/ubuntu:18.10
  konstruktoid/ubuntu:19.04
  konstruktoid/ubuntu:latest
  nginx:latest
  nginx:mainline-alpine
  nginx:stable-alpine
  opensuse:latest
  opensuse/leap:latest
  opensuse/tumbleweed
  oraclelinux:5
  oraclelinux:6
  oraclelinux:7
  oraclelinux:8
  oraclelinux:latest
  ubuntu:14.04.5
  ubuntu:16.04
  ubuntu:16.10
  ubuntu:17.04
  ubuntu:17.10
  ubuntu:18.04
  ubuntu:18.10
  ubuntu:19.04
  ubuntu:20.04
  ubuntu:latest
"

LANG=C date -u > docker_images_result
IMGTMP="$(mktemp)"

for base in $IMAGES; do
  image=$(echo "$base" | sed -e 's/\//_/g' -e 's/:/_/g')
  docker pull "$base"
  docker save -o "$image.tar" "$base"
  du -h "$image.tar" >> "$IMGTMP"
  rm "$image.tar"
  docker rmi "$base"
done

sort -k1 -n "$IMGTMP" >> docker_images_result
rm "$IMGTMP"

docker run --rm --read-only --tmpfs /tmp:rw,nosuid,nodev -v /var/run/docker.sock:/var/run/docker.sock konstruktoid/docker-garby
