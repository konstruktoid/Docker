#!/bin/sh
# https://jpetazzo.github.io/2015/05/27/docker-images-vulnerabilities/
#

BASE=~/Git
U=$(curl -s "https://www.debian.org/security/dsa")
UDATE=$(echo "$U" | grep -oP "(?<=<dc:date>)[^<]+" | head -n1)
DEBUPD=$(date -d "$UDATE" +%s)

cd "$BASE"
for d in $(find $BASE/*_Build -name "Dockerfile"); do
  if grep '# Force autobuild' "$d"; then
    if [ "$(grep '# Force autobuild' "$d" | awk '{print $NF}')" -lt "$DEBUPD" ]; then
      echo "$d ($(grep '# Force autobuild' "$d" | awk '{print $NF}')) is older than $DEBUPD"
      cd "$(echo "$d" | sed 's/Dockerfile//g')"
      git co master
      sed -i "s/# Force autobuild.*/# Force autobuild $(date +%s)/" "$d"
      git add Dockerfile
      git commit -m "Force autobuild"
      git push -f
      cd "$BASE"
    fi
  fi
done
