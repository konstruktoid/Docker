#!/usr/bin/python3
"""Fetch and print the size of various Docker images."""

import datetime
import ssl
import urllib.request
import json
from urllib.error import HTTPError

distributions = [
    "library/alpine",
    "library/busybox",
    "library/centos",
    "library/debian",
    "library/fedora",
    "konstruktoid/alpine",
    "konstruktoid/debian",
    "konstruktoid/nginx",
    "konstruktoid/ubuntu",
    "library/nginx",
    "opensuse/leap",
    "opensuse/tumbleweed",
    "library/oraclelinux",
    "library/ubuntu",
]

with open("docker_image_result", "w") as docker_image_result:
    docker_image_result.write(
        "# "
        + str(datetime.datetime.utcnow())
        + "\n"
        + "# grep -v '^#' docker_image_result | sort -k1 -n\n\n"
    )

for DISTRIBUTION in distributions:
    try:
        URL = (
            "https://registry.hub.docker.com/v2/repositories/"
            + DISTRIBUTION
            + "/tags?page_size=1024"
        )

        if URL.lower().startswith("https"):
            req = urllib.request.urlopen(URL, context=ssl.SSLContext())
        else:
            raise ValueError("URL does not start with https")

        with req as URL:
            data = json.loads(URL.read().decode())
            datadict = dict()
            datadict = data

            for k in datadict["results"]:
                last_updated_hub = datetime.datetime.strptime(
                    k["last_updated"][:10], "%Y-%m-%d"
                )
                full_size_mb = round(((k["full_size"] / 1024) / 1024), 2)
                last_updated = datetime.datetime.timestamp(last_updated_hub)
                current_time = datetime.datetime.timestamp(datetime.datetime.utcnow())
                DISTRIBUTION = DISTRIBUTION.replace("library/", "")
                info = "%sM\t%s:%s" % (full_size_mb, DISTRIBUTION, k["name"])

                if (last_updated - current_time) <= 2678400 and k["full_size"] > 1:
                    with open("docker_image_result", "a") as docker_image_result:
                        docker_image_result.write(info + "\n")

    except HTTPError as ex:
        print(ex.read())
