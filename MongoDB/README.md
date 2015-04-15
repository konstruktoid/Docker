
*Dockerized MongoDB 3.X with WiredTiger*     
A Docker three node MongoDB replica set.     
    
Automatic build available at https://registry.hub.docker.com/u/konstruktoid/mongodb/    
    
http://konstruktoid.net/2015/02/09/dockerized-mongodb-3-x-rc-with-wiredtiger/    
$ docker run --rm  -p 27017:27017 -p 27018:27018 -p 27019:27019 -i -t mongodb    
# /bin/bash /etc/mongod/mongostart.sh   
$ mongo --port 27017   
