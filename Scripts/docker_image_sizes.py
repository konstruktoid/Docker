#!/usr/bin/python3

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
        + str(datetime.datetime.utcnow())  # noqa: W503
        + "\n"  # noqa: W503
        + "# grep -v '^#' docker_image_result | sort -k1 -n\n\n"  # noqa: W503
    )

for distribution in distributions:
    try:
        url = (
            "https://registry.hub.docker.com/v2/repositories/"
            + distribution  # noqa: W503
            + "/tags?page_size=1024"  # noqa: W503
        )

        if url.lower().startswith("https"):
            req = urllib.request.urlopen(url, context=ssl.SSLContext())
        else:
            raise ValueError("url does not start with https")

        with req as url:
            data = json.loads(url.read().decode())
            datadict = dict()
            datadict = data

            for k in datadict["results"]:
                last_updated_hub = datetime.datetime.strptime(
                    k["last_updated"][:10], "%Y-%m-%d"
                )
                full_size_mb = round(((k["full_size"] / 1024) / 1024), 2)
                last_updated = datetime.datetime.timestamp(last_updated_hub)
                current_time = datetime.datetime.timestamp(datetime.datetime.utcnow())
                distribution = distribution.replace("library/", "")
                info = "%sM\t%s:%s" % (full_size_mb, distribution, k["name"])

                if (last_updated - current_time) <= 2678400 and k["full_size"] > 1:
                    with open("docker_image_result", "a") as docker_image_result:
                        docker_image_result.write(info + "\n")

    except HTTPError as ex:
        print(ex.read())
