# Docker Security Cheat Sheet  
  
```sh
~$ docker version
Client version: 1.6.2
Client API version: 1.18
Go version (client): go1.4.2
Git commit (client): 7c8fca2
OS/Arch (client): linux/amd64
Server version: 1.6.2
Server API version: 1.18
Go version (server): go1.4.2
Git commit (server): 7c8fca2
OS/Arch (server): linux/amd64
```

##Docker daemon host documentation
Lock down with a firewall, remove SUID/GUID, password policies, stricter SSH configuration, and so on.  

**Ubuntu/Debian**  
[Hardening Ubuntu. Systemd edition.](https://github.com/konstruktoid/hardening/)  
[CIS Ubuntu 14.04 LTS Server Benchmark v1.0.0](https://benchmarks.cisecurity.org/downloads/show-single/?file=ubuntu1404.100)  
[StricterDefaults](https://help.ubuntu.com/community/StricterDefaults)  

**RedHat/Fedora**  
[A Guide to securing Red Hat Enterprise Linux 7](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/)  
[CIS Red Hat Enterprise Linux 7 Benchmark v1.0.0](https://benchmarks.cisecurity.org/downloads/show-single/?file=rhel7.100)  

**General**  
[Operating System Security Requirements Guide (UNIX Version)](http://stigviewer.com/stig/unix_srg/)  
[Deploy and harden a host with Docker Machine](http://konstruktoid.net/2015/02/23/deploy-and-harden-a-host-with-docker-machine/)  

## Docker security documentation  
[Docker Security](https://docs.docker.com/articles/security/)  
[Introduction to Container Security](https://d3oypxn00j2a10.cloudfront.net/assets/img/Docker%20Security/WP_Intro_to_container_security_03.20.2015.pdf) (PDF)  
[CIS Docker 1.6 Benchmark v1.0.0](https://benchmarks.cisecurity.org/downloads/show-single/index.cfm?file=docker16.100) (PDF)  
[Before you initiate a “docker pull”](https://securityblog.redhat.com/2014/12/18/before-you-initiate-a-docker-pull/)    

##Docker daemon options  
`--icc=false` Use `--link` on run instead.  
`--selinux-enabled` Enable if using SELinux.  
`--default-ulimit` Set strict limits as default, it's overwritten by `--ulimit` on run.  
`--tlsverify` Enable TLS, [Protecting the Docker daemon Socket with HTTPS](https://docs.docker.com/articles/https/).  

`$ docker -d --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem -H=0.0.0.0:2376 -icc=false --default-ulimit nproc=512:1024 --default-ulimit nfile=50:100`

##Docker run options  
###Capabilities  
`--cap-drop=all` Drop all capabilities by default.  
`--cap-add net_admin` Allow only needed.  

**Using capsh**  
```sh  
~$ docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                           NAMES
82ae0cd169d3        nginx:latest        "nginx -g 'daemon of   About an hour ago   Up About an hour    443/tcp, 0.0.0.0:8080->80/tcp   nginx
~$ docker exec `docker ps -q` pgrep -a nginx
1 nginx: master process nginx -g daemon off;
9 nginx: worker process
~$ docker exec `docker ps -q` cat /proc/1/status | grep CapEff | awk '{print $NF}'
00000000a80425fb
~$ docker exec `docker ps -q` capsh --decode=00000000a80425fb | sed -e 's/.*=//' -e 's/cap_/--cap-add /g' -e 's/,/ /g'
--cap-add chown --cap-add dac_override --cap-add fowner --cap-add fsetid --cap-add kill --cap-add setgid --cap-add setuid --cap-add setpcap --cap-add net_bind_service --cap-add net_raw --cap-add sys_chroot --cap-add mknod --cap-add audit_write --cap-add setfcap
```  

**Using getpcaps**  
```sh
~$ docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                           NAMES
82ae0cd169d3        nginx:latest        "nginx -g 'daemon of   About an hour ago   Up About an hour    443/tcp, 0.0.0.0:8080->80/tcp   nginx
~$ docker exec `docker ps -q` pgrep -a nginx
1 nginx: master process nginx -g daemon off;
9 nginx: worker process
~$ export getTMP=`mktemp XXXXXX` && docker exec `docker ps -q` /sbin/getpcaps 1 2> $getTMP && cat $getTMP | sed -e 's/.*=//' -e 's/cap_/--cap-add /g' -e 's/,/ /g'
--cap-add chown --cap-add dac_override --cap-add fowner --cap-add fsetid --cap-add kill --cap-add setgid --cap-add setuid --cap-add setpcap --cap-add net_bind_service --cap-add net_raw --cap-add sys_chroot --cap-add mknod --cap-add audit_write --cap-add setfcap+eip
```  

For reference:  
```sh
~$ curl https://raw.githubusercontent.com/torvalds/linux/master/include/uapi/linux/capability.h | grep " CAP_" | awk '{print $2, $3}'
```

###Cgroups  
`--cgroup-parent` Parent cgroup for the container.  

###Devices  
`--device` Mount read-only if required.  

###Labels  
`--security-opt="apparmor:profile"` Set the AppArmor profile to be applied to the container.  
`--security-opt label:type:lxc_nonet_t` Set the SELinux label to be applied to the container.  

###Log and logging drivers  
`-v /dev/log:/dev/log`
`--log-driver`  Send container logs to other systems such as Syslog.

###Memory and CPU limits  
`--cpuset-cpus` CPUs in which to allow execution (0-3, 0,1).  
` -m, --memory` Memory limit.  
`--memory-swap""` Total memory limit.  
`--ulimit` Set the ulimit on the specific container.  

###Networking  
`-p IP:host_port:container_port` or `-p IP::port` Specify the external interface.  

###Time  
`-v /etc/localtime:/etc/localtime:ro`  

###User  
`-u, --user` Run as a unprivileged user.  

###Volumes and mounting
`--read-only` Mount container root filesystem as read only.  
`-v /volume:ro` Mount volumes read only if possible.  

##Dockerfile example
```sh
FROM debian:wheezy [1]

COPY files/example /tmp/example [2]
ADD https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/cleanBits.sh /tmp/cleanBits.sh [3]

RUN \
    apt-get update && \
    apt-get -y upgrade && \ [4]
    apt-get -y clean && \
    apt-get -y autoremove

RUN \
    useradd --system --no-create-home --user-group --shell /bin/false dockeru && \ [5]
    /bin/bash /tmp/cleanBits.sh

ENTRYPOINT ["/bin/bash"]
CMD []
```

1. Do we trust the remote repository? Is there any reason we're not using a homebuilt base image?  
2. COPY local files  
3. ADD remote files
4. Keep the container up-to-date
5. Use a local unprivileged user account

###Docker run example
`~$ export CAP="--cap-drop all --cap-add net_admin"`  

If root user is required:  
`~$ docker run --rm -v /etc/localtime:/etc/localtime:ro -v /dev/log:/dev/log $CAP --name <NAME> -t <IMAGE>`  

Unpriv user if possible:  
`~$ docker run --rm -u dockeru -v /etc/localtime:/etc/localtime:ro -v /dev/log:/dev/log $CAP --name <NAME> -t <IMAGE>`  

## Misc
### dockertarsum  
Like the system sum utilites (md5sum, sha1sum, sha256sum, etc), this is a command line tool to get the fixed time checksum of docker image layers.  
dockertarsum is available at https://github.com/vbatts/docker-utils#dockertarsum.
