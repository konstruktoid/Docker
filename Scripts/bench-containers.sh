#!/bin/sh

# This script spawns alot of containers in order to test
# docker-bench-security (https://github.com/docker/docker-bench-security)
#
# GC: https://github.com/konstruktoid/docker-garby

pullImages="
konstruktoid/nginx
busybox
"

containerOpts="
0_0;STANDARD;;alpine;sleep 1000
4_1;PASS;--user nobody;alpine;sleep 1000
5_1;PASS;--security-opt apparmor=docker-default;alpine;sleep 1000
5_1;FAIL;--security-opt apparmor=unconfined;alpine;sleep 1000
5_3;FAIL;--cap-add=audit_control;alpine;sleep 1000
5_4;FAIL;--privileged;alpine;sleep 1000
5_5;FAIL;-v /tmp:/tmp/htmp -v /etc:/tmp/etc -v /etc/ssh;alpine;sleep 1000
5_7;FAIL;-p 80:1234;alpine;sleep 1000
5_9;FAIL;--net=host;alpine;sleep 1000
5_10;PASS;--memory 120m;alpine;sleep 1000
5_11;PASS;--cpu-shares 100;alpine;sleep 1000
5_12;PASS;--read-only;alpine;sleep 1000
5_13;PASS;-p 127.0.0.1:1022:9182;alpine;sleep 1000
5_14;PASS;--restart on-failure:5;alpine;sleep 1000
5_15;FAIL;--pid=host;alpine;sleep 1000
5_16;FAIL;--ipc=host;alpine;sleep 1000
5_17;FAIL;--device=/dev/tty0:/dev/tty0;alpine;sleep 1000
5_18;PASS;--ulimit nofile=1024:1024;alpine;sleep 1000
5_19;FAIL;--volume=/tmp:/tmp:shared;alpine;sleep 1000
5_20;FAIL;--uts=host;alpine;sleep 1000
5_21;FAIL;--security-opt seccomp:unconfined;alpine;sleep 1000
5_24;FAIL;--cgroup-parent=/test_5_24;alpine;sleep 1000
5_25;PASS;--security-opt no-new-privileges;alpine;sleep 1000
5_28;PASS;--pids-limit 666;alpine;sleep 1000
5_30;FAIL;--userns=host;alpine;sleep 1000
5_31;FAIL;-v /var/run/docker.sock;alpine;sleep 1000
"

if ! docker info 2>/dev/null 1>&2; then
  echo "The docker daemon doesn't seem to be running"
  exit 1
fi

for i in ${pullImages}; do
  docker pull "${i}"
done

echo "${containerOpts}"| while read -r line; do
  testnum=$(echo "${line}" | cut -f1 -d\;)
  testresult=$(echo "${line}" | cut -f2 -d\;)
  copts=$(echo "${line}" | cut -f3 -d\;)
  cimage=$(echo "${line}" | cut -f4 -d\;)
  ccommand=$(echo "${line}" | cut -f5 -d\;)

  if [ -n "${cimage}" ]; then
    docker rm -f "test_${testresult}_${testnum}" 2>/dev/null 1>&2
    echo "test_${testresult}_${testnum}"
    docker run -d --name "test_${testresult}_${testnum}" ${copts} ${cimage} ${ccommand}
  fi
done

docker run --rm --read-only --tmpfs /tmp:rw,nosuid,nodev -v /var/run/docker.sock:/var/run/docker.sock konstruktoid/docker-garby
