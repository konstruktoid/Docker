FROM ubuntu:latest

ADD https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/cleanBits.sh /tmp/cleanBits.sh

RUN \
        apt-get update && \
        apt-get -y upgrade && \
        apt-get -y clean && \ 
	apt-get -y autoremove

RUN \
	adduser --system --no-create-home --group --disabled-password --shell /bin/false dockeru && \
	/bin/bash /tmp/cleanBits.sh

CMD ["bash"]
