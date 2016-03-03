FROM alpine:3.3

ENV VERSION 1.10.2
ENV SHA256 de4057057acd259ec38b5244a40d806993e2ca219e9869ace133fad0e09cedf2

WORKDIR /usr/bin

RUN apk update && \
    apk upgrade && \
    apk --update add coreutils curl && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION > docker-$VERSION && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.sha256 > docker-$VERSION.sha256 && \
    sha256sum -c docker-$VERSION.sha256 && \
    echo "$SHA256 docker-$VERSION" | sha256sum -c - && \
    ln -s docker-$VERSION docker && \
    chmod u+x docker-$VERSION && \
    apk del curl && \
    rm -rf /var/cache/apk/*

COPY ./docker-garby.sh /docker-garby.sh

ENTRYPOINT ["/bin/sh", "/docker-garby.sh"]
