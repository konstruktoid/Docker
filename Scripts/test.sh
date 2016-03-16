#!/bin/sh
#
# quick and dirty shell linter.
# this script will mark itself as a failure since "$1" is not set.

if [ -z "$1" ]; then
  echo "Please verify the arguments."
  exit 1
elif ! file "$1" | grep 'shell script' 1>/dev/null; then
  echo "Not a shell script."
  exit 1
else
  echo "Testing $1"
fi

shellcheck -s ksh "$1"
dash -e -u "$1"
