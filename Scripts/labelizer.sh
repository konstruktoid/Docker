#!/bin/sh

if ! [ -f Dockerfile ]; then
  echo "Dockerfile is not present. Exiting."
  exit 1
fi

TMPFILE="$(mktemp)"
VCSURL="$(git remote get-url --push $(git remote))"
NAME="$(basename $(git rev-parse --show-toplevel) | sed -e 's/_.*//' | tr '[:upper:]' '[:lower:]')"

grep 'FROM' Dockerfile > "$TMPFILE"

cat << LABELBLOCK >> "$TMPFILE"

LABEL org.label-schema.name="$NAME" \
      org.label-schema.vcs-url="$VCSURL"
LABELBLOCK

grep -v 'FROM' Dockerfile >> "$TMPFILE"

cp "$TMPFILE" Dockerfile
rm "$TMPFILE"
