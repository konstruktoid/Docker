FROM ubuntu:latest

COPY ./files/ /etc/mongod/

RUN \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
	echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/testing multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list && \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y mongodb-org && \
	apt-get -y clean && apt-get -y autoremove

RUN \
	mkdir -p /data/db01 /data/db02 /data/db03 && \
	chown -R mongodb:mongodb /data/db* && \
	chmod u+x /etc/mongod/mongostart.sh

CMD ["bash"]
