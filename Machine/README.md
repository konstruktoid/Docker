**Deploy and harden a Docker host on _DigitalOcean_ with _Docker Machine_**     
     
Treat this as pre-alpha WIP, and read the code.    
Before you begin you need to set your DigitalOcean access token in the script.     
createMachine.sh will download https://github.com/docker/machine/releases/download/v0.1.0-rc4/docker-machine_linux-amd64 and move it to /usr/local/bin/docker-machine unless already available.     
When docker-machine is available it will create a host on *ams2* with the name you specified.     
It will then download and run https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh, which is a script to create a minimal level of security.     
     
*baselineDockerHost.sh* installs a basic firewall before it upgrades all packages installed on the host.     
The packages *apparmor-profiles*, *haveged* and *ntp* are installed.     
*hosts.allow* and *hosts.deny* as well as *cron* and *at* are configured.    
Some users are remove.     
SUID bits are removed.     
Docker option *icc* is set to false.     
NTP is then configured and old and unused packages are removed.

**Build a image**     

```
~$ $(docker-machine env remotehost)     
~$ docker info
Containers: 0
Images: 0
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
Execution Driver: native-0.2
Kernel Version: 3.13.0-43-generic
Operating System: Ubuntu 14.04.2 LTS
CPUs: 1
Total Memory: 490 MiB
Name: remotehost
ID: K772:A3T6:O4SY:FTSI:RSRV:IBYZ:6T32:2DP5:6WRN:BEVY:PJW2:UZBF
WARNING: No swap limit support
$ docker build -t cleanbits https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/Dockerfile.example
...
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
cleanbits           latest              16071d0d3824        22 seconds ago      188.8 MB
ubuntu              14.04               2d24f826cb16        44 hours ago        188.3 MB
ubuntu              14.04.2             2d24f826cb16        44 hours ago        188.3 MB
ubuntu              latest              2d24f826cb16        44 hours ago        188.3 MB
ubuntu              trusty              2d24f826cb16        44 hours ago        188.3 MB
ubuntu              trusty-20150218.1   2d24f826cb16        44 hours ago        188.3 MB
$ docker-machine ssh remotehost 'docker images'
REPOSITORY          TAG                 IMAGE ID            CREATED              VIRTUAL SIZE
cleanbits           latest              16071d0d3824        About a minute ago   188.8 MB
ubuntu              trusty              2d24f826cb16        44 hours ago         188.3 MB
ubuntu              trusty-20150218.1   2d24f826cb16        44 hours ago         188.3 MB
ubuntu              14.04               2d24f826cb16        44 hours ago         188.3 MB
ubuntu              14.04.2             2d24f826cb16        44 hours ago         188.3 MB
ubuntu              latest              2d24f826cb16        44 hours ago         188.3 MB
```
