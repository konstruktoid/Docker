~# bash createMachine machine
~# $(docker-machine env machine)
~# docker build -t cleanbits -f Dockerfile.example .
~# docker run --rm -v /dev/log:/dev/log --cap-drop all -t -i cleanbits ping www.google.com
ping: icmp open socket: Operation not permitted
~# docker run --rm -v /dev/log:/dev/log -t -i cleanbits ping www.google.com
PING www.google.com (74.125.136.99) 56(84) bytes of data.
64 bytes from ea-in-f99.1e100.net (74.125.136.99): icmp_seq=1 ttl=50 time=5.68 ms
64 bytes from ea-in-f99.1e100.net (74.125.136.99): icmp_seq=2 ttl=50 time=5.45 ms