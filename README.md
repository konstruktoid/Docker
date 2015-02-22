** Deploy and harden a Docker host on _DigitalOcean_ with _Docker Machine_ **     
     
Treat this as pre-alpha WIP, and read the code.    
Before you begin you need to set your DigitalOcean access token in the script.     
createMachine.sh will download https://github.com/docker/machine/releases/download/v0.1.0-rc4/docker-machine_linux-amd64 and move it to /usr/local/bin/docker-machine unless already available.     
When docker-machine is available it will create a host on *ams2* with the name you specified.     
It will then download and run https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh, which is a script to create a minimal level of security.     
     
*baselineDockerHost.sh* installs a basic firewall before it upgrades all packages installed on the host.     
The packages *apparmor-profiles*, *haveged* and *ntp* are installed.     
*hosts.allow* and *hosts.deny* as well as *cron* and *at* are configured.    
The user *dockeru* is added and other users are remove.     
SUID bits are removed.     
Docker option *icc* is set to false.     
NTP is then configured and old and unused packages are removed.
