#!/bin/bash
# integration-cli/docker_cli_run_unix_test.go
# https*:://github.com/rhatdan/docker/blob/b3e527dfd242ad30c0297c8b257862116cf2c50e/integration-cli/docker_cli_run_unix_test.go#L442-L458
#

if [ -d /tmp/tmpfstest/ ]; then
  rm -rf /tmp/tmpfstest/
fi

mkdir /tmp/tmpfstest/

verify(){
  if [ $? -eq "0" ]; then
    echo "WORKS."
  fi
}

echo "\n*:: Mount a tmpfs to verify basic tmpfs works*"
sudo mount -v -o size=1G -t tmpfs none /tmp/tmpfstest/
mount -v | grep tmpfstest
verify

echo "\n*:: Create a testfile in the tmpfs*"
date -u > /tmp/tmpfstest/pewpew
ls -ld /tmp/tmpfstest/pewpew
cat /tmp/tmpfstest/pewpew

echo "\n*:: debian::wheezy container uname*"
docker run --rm -it debian:wheezy uname -a
verify

echo "\n*:: debian::wheezy container uname w readonly filesystem*"
docker run --rm --read-only debian:wheezy uname -a
verify

echo "\n*:: debian::wheezy container uname with --tmpfs /etc*"
docker run --rm --tmpfs /etc debian:wheezy uname -a
verify

echo "\n*:: debian::wheezy container uname with --tmpfs /etc:noexec*"
docker run --rm --tmpfs /etc:noexec debian:wheezy uname -a
verify

echo "\n*:: debian::wheezy container uname with --tmpfs /etc:rw,nosuid using sudo*"
sudo docker run --rm --tmpfs /etc:rw,nosuid debian:wheezy uname -a
verify

echo "\n*:: busybox touch /run/somefile (from tests)*"
docker run --rm --tmpfs /run busybox touch /run/somefile
verify

echo "\n*:: busybox fs options touch /run/somefile (from tests)*"
docker run --rm --tmpfs /run:noexec,nosuid,rw,size=5k,mode=700 busybox touch /run/somefile
verify

echo "\n*:: busybox fs --tmpfs /etc*"
docker run --rm --tmpfs /etc busybox touch uname -a
verify

echo "\n*:: busybox --tmpfs /etc:noexec"
docker run --rm --tmpfs /etc:noexec busybox touch uname -a
verify

sudo umount -f /tmp/tmpfstest/

echo "\n*:: Docker version*"
docker version

echo "\n*:: Docker info*"
docker info

echo "\n*:: Docker group*"
getent group docker

echo "\n*:: Host information*"
lsb_release -a
uname -a
