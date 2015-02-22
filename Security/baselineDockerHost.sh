#!/bin/bash

FW_CONF="https://raw.githubusercontent.com/konstruktoid/ubuntu-conf/master/net/firewall.conf"
FW_POLICY="https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/firewall.docker"
NTP="https://raw.githubusercontent.com/konstruktoid/ubuntu-conf/master/net/ntpconf.sh"
ADMINIP=`grep "Accepted publickey" /var/log/auth.log | awk '{print $11}' | sort | uniq`

echo ":: Setting up a firewall"
curl $FW_CONF > /etc/init/firewall.conf
curl $FW_POLICY > /etc/init.d/firewall
update-rc.d firewall defaults 
sed -i "s/ADMIN=.*/ADMIN="$ADMINIP"/" /etc/init.d/firewall
chmod u+x /etc/init.d/firewall
bash /etc/init.d/firewall

echo ":: Upgrading installed packages"
apt-get update
apt-get -y upgrade

echo ":: Installing packages"
apt-get -y install apparmor-profiles haveged ntp

echo ":: Host settings and cron"
echo sshd : ALL : ALLOW$'\n'ALL: LOCAL, 127.0.0.1 > /etc/hosts.allow
echo ALL: PARANOID > /etc/hosts.deny
echo root > /etc/cron.allow
echo root > /etc/at.allow

echo ":: Removing users"
for users in games gnats irc news uucp; 
do 
	sudo userdel -r $users 2> /dev/null
done

echo ":: Removing suid"
for p in /bin/fusermount /bin/mount /bin/ping /bin/ping6 /bin/su /bin/umount /usr/bin/bsd-write /usr/bin/chage /usr/bin/chfn /usr/bin/chsh /usr/bin/mlocate /usr/bin/mtr /usr/bin/newgrp /usr/bin/pkexec /usr/bin/traceroute6.iputils /usr/bin/wall /usr/sbin/pppd;
do 
	oct=`stat -c "%a" $p |sed 's/^4/0/'`
	ug=`stat -c "%U %G" $p`
	dpkg-statoverride --remove $p 2> /dev/null
	dpkg-statoverride --add $ug $oct $p 2> /dev/null
	chmod -s $p
done

for SHELL in `cat /etc/shells`; do
	if [ -x $SHELL ]; then
		chmod -s $SHELL
	fi
done

echo ":: Changing default Docker options"
sed -i 's/DOCKER_OPTS="/DOCKER_OPTS="--icc=false /' /etc/default/docker
sed -i "s/DOCKER_OPTS='/DOCKER_OPTS='--icc=false /" /etc/default/docker
service docker restart

echo ":: Setting up NTP"
NTPTEMP="`mktemp`"
curl $NTP > $NTPTEMP
sed -i 's/APPLY="no"/APPLY="YES"/' $NTPTEMP
bash $NTPTEMP

echo ":: Cleaning"
apt-get -y clean
apt-get -y autoremove
