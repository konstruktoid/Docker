# Docker Security Cheat Sheet  
  
```sh
$ docker version
Client:
 Version:      1.10.0-dev
 API version:  1.22
 Go version:   go1.5.1
 Git commit:   67630be
 Built:        Tue Nov  3 23:29:03 UTC 2015
 OS/Arch:      linux/amd64
 Experimental: true

Server:
 Version:      1.10.0-dev
 API version:  1.22
 Go version:   go1.5.1
 Git commit:   67630be
 Built:        Tue Nov  3 23:29:03 UTC 2015
 OS/Arch:      linux/amd64
 Experimental: true
```

## Docker daemon host documentation
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
[Before you initiate a “docker pull”](https://securityblog.redhat.com/2014/12/18/before-you-initiate-a-docker-pull/)  
[CIS Docker 1.6 Benchmark v1.0.0](https://benchmarks.cisecurity.org/downloads/show-single/index.cfm?file=docker16.100) (PDF)  
[Docker Security](https://docs.docker.com/articles/security/)  
[Docker Security Cheat Sheet](http://container-solutions.com/content/uploads/2015/06/15.06.15_DockerCheatSheet_A2.pdf) (PDF)  
[Introduction to Container Security](https://d3oypxn00j2a10.cloudfront.net/assets/img/Docker%20Security/WP_Intro_to_container_security_03.20.2015.pdf) (PDF)  
[Secrets: write-up best practices, do's and don'ts, roadmap](https://github.com/docker/docker/issues/13490)  
[Securing Docker Containers with sVirt and Trusted Sources](http://crunchtools.com/securing-docker-svirt/)  
[Why we don't let non-root users run Docker](http://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/)  

## Docker security tools
### Bane
Custom AppArmor profile generator for Docker containers, available at https://github.com/jfrazelle/bane.

### Docker Bench for Security
Docker Bench for Security is a script that checks for all the automatable tests included in the [CIS Docker 1.6 Benchmark](https://benchmarks.cisecurity.org/downloads/show-single/index.cfm?file=docker16.100).  
Docker Bench for Security is available at https://dockerbench.com.

### dockertarsum  
Like the system sum utilites (md5sum, sha1sum, sha256sum, etc), this is a command line tool to get the fixed time checksum of docker image layers.  
dockertarsum is available at https://github.com/vbatts/docker-utils#dockertarsum.  

### Notary
The Notary project comprises a server and a client for running and interacting with trusted collections. See [Notary](https://github.com/docker/notary).

## Docker daemon options  
`--icc=false` Use `--link` on run instead.  
`--selinux-enabled` Enable if using SELinux.  
`--default-ulimit` Set strict limits as default, it's overwritten by `--ulimit` on run.  
`--tlsverify` Enable TLS, [Protecting the Docker daemon Socket with HTTPS](https://docs.docker.com/articles/https/). [genCert.sh](https://github.com/konstruktoid/Docker/blob/master/Scripts/genCert.sh) is a script to automatically generate certificates.  
`--userns-remap=default` Enable user namespace.  

`/usr/bin/docker daemon -s overlay --userns-remap=default --tlsverify --tlscacert=/etc/ssl/docker/ca.pem --tlscert=/etc/ssl/docker/server-cert.pem --tlskey=/etc/ssl/docker/server-key.pem --icc=false --default-ulimit nproc=512:1024 --default-ulimit nofile=50:100 -H=0.0.0.0:2376 -H fd://`

## Docker run options  
### Capabilities  
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

### Cgroups  
`--cgroup-parent` Parent cgroup for the container.  

### Devices  
`--device` Mount read-only if required.  

### Labels  
`--security-opt="apparmor:profile"` Set the AppArmor profile to be applied to the container.  
`--security-opt label:type:lxc_nonet_t` Set the SELinux label to be applied to the container.  

### Log and logging drivers  
`-v /dev/log:/dev/log`  
`--log-driver` Send container logs to other systems such as Syslog, see https://docs.docker.com/reference/logging/overview/.

### Memory and CPU limits
`--cpu-shares` CPU shares (relative weight).  
`--cpu-period` Limit CPU CFS (Completely Fair Scheduler) period.  
`--cpu-quota` Limit CPU CFS (Completely Fair Scheduler) quota.  
`--cpuset-cpus` CPUs in which to allow execution (0-3, 0,1).  
`--cpuset-mems` MEMs in which to allow execution (0-3, 0,1).  
`--kernel-memory` Kernel memory limit.  
`-m, --memory` Memory limit.  
`--memory-reservation` Memory soft limit.  
`--memory-swap` Total memory (memory + swap), '-1' to disable swap.  
`--ulimit` Set the ulimit on the specific container.  

### Networking  
`-p IP:host_port:container_port` or `-p IP::port` Specify the external interface.  

### Time  
`-v /etc/localtime:/etc/localtime:ro`  

### Seccomp
`--security-opt seccomp:/path/to/seccomp/profile.json` See [Seccomp security profiles for Docker](https://github.com/docker/docker/blob/master/docs/security/seccomp.md), [genSeccomp.sh](https://github.com/konstruktoid/Docker/blob/master/Scripts/genSeccomp.sh) is a basice profile generator.  

### Trust
`--disable-content-trust` See [Content trust in Docker](https://docs.docker.com/security/trust/content_trust/)  

### User  
`-u, --user` Run as a unprivileged user.  

### Volumes and mounting
`--read-only` Mount container root filesystem as read only.  
`-v /volume:ro` Mount volumes read only if possible.  

## Dockerfile example
```sh
FROM debian:wheezy [1]

COPY files/example /tmp/example [2]
ADD https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/cleanBits.sh /tmp/cleanBits.sh [3]

RUN \
    apt-get update && \
    apt-get -y upgrade && \ [4]
    apt-get -y clean

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

### Docker run example
`~$ export CAP="--cap-drop all --cap-add net_admin"`  

If root user is required:  
`~$ docker run --rm -v /etc/localtime:/etc/localtime:ro -v /dev/log:/dev/log $CAP --name <NAME> -t <IMAGE>`  

Unpriv user if possible:  
`~$ docker run --rm -u dockeru -v /etc/localtime:/etc/localtime:ro -v /dev/log:/dev/log $CAP --name <NAME> -t <IMAGE>`  

## Garbage collection
### docker-gc
[spotify/docker-gc](https://github.com/spotify/docker-gc)  
### docker-garby
[konstruktoid/docker-garby](https://github.com/konstruktoid/docker-garby)  
