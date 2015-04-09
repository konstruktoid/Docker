*Automated build available at https://registry.hub.docker.com/u/konstruktoid/cleanbits/ *     
     
*Build the _cleanbits_ container*    
~$ docker build -t cleanbits -f Dockerfile.example .    
     
*Drop all capabilites and run ping as root*    
~$ docker run --rm -v /dev/log:/dev/log --cap-drop all -t -i cleanbits ping www.google.com    
ping: icmp open socket: Operation not permitted    
     
*Drop all capabilities except net_raw as root*     
$ docker run --rm -v /dev/log:/dev/log --cap-drop all --cap-add net_raw -t -i cleanbits ping www.google.com    
PING www.google.com (74.125.71.147) 56(84) bytes of data.    
64 bytes from 74.125.71.147: icmp_seq=1 ttl=43 time=48.7 ms    
64 bytes from 74.125.71.147: icmp_seq=2 ttl=43 time=45.8 ms    
     
*Default run with all capabilites*        
~$ docker run --rm -v /dev/log:/dev/log -t -i cleanbits ping www.google.com    
PING www.google.com (74.125.136.99) 56(84) bytes of data.    
64 bytes from ea-in-f99.1e100.net (74.125.136.99): icmp_seq=1 ttl=50 time=5.68 ms    
64 bytes from ea-in-f99.1e100.net (74.125.136.99): icmp_seq=2 ttl=50 time=5.45 ms    
     
*Run as user dockeru and with suid removed*     
~$ docker run -u dockeru --rm -v /dev/log:/dev/log -t -i cleanbits ping www.google.com    
ping: icmp open socket: Operation not permitted    
