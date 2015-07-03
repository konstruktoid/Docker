#!/bin/sh
storage='/tmp'
log="$storage/dockbk.log"

ccnt=$(docker ps -q | wc -l | awk '{print $1}')
ecnt=0

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Starting export of Docker containers${normal}"
echo "    - $ccnt running containers"
echo "    - target directory: $storage"
echo "    - log file: $log"
echo

if test -e "$log" && grep "Last run" "$log"; then
  sed --in-place=".bak" "s/^# Last run.*/# Last run $(date)/" "$log"
  else
  echo "# Last run $(date)" > "$log"
fi

cmd=$(docker ps -q)
for b in $cmd; do
  name=$(docker inspect -f \{\{.Name\}\} "$b"| tr -d '/')
  time=$(date +%y%m%d%H%M%S)
  filename="$name-$time.tar"

  ecnt=$((ecnt + 1))
  echo "[$ecnt/$ccnt] $name"

  echo "    - exporting $name to $storage/$filename"
  docker export -o "$storage/$filename" "$b"

  echo "    - compressing $filename"
  gzip "$storage/$filename"

  sum=$(openssl sha1 -sha256 "$storage/$filename.gz")
  echo "$sum" >> "$log"
  echo "    - $filename.gz checksum $(echo "$sum" | awk '{print $NF}')"

  echo
done
