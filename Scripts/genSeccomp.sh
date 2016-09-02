#!/bin/sh
# Writes a .json file named seccomp-<date>.json with the blocked syscalls defined in a file
#
# docker run -ti --security-opt seccomp:/file/path/seccomp-1512132157.json busybox sh
#
# https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl

date="$(date -u +%y%m%d%H%M)"

if [ -z "$1" ]; then
  echo "Argument missing, which should be file with a syscall per line."
  exit 1
else
  FILE="$1"
fi

PREFILE="$(mktemp)"
CALLSPREFILE="$(mktemp)"
POSTFILE="seccomp-$date.json"

start(){
echo "
{
    'defaultAction': 'SCMP_ACT_ALLOW',
    'syscalls': ["
}

calls(){
while read call
do
  echo "
        {
              'name': '$call',
              'action': 'SCMP_ACT_ERRNO'
         },"
done < "$FILE"
}

end(){
echo '
    ]
}
'
}

start > "$PREFILE"
calls > "$CALLSPREFILE"
sed '$ s/.$//' "$CALLSPREFILE" >> "$PREFILE"
end >> "$PREFILE"
sed -e 's/'\''/"/g' -e '/^\s*$/d' "$PREFILE" > "$POSTFILE"

rm "$PREFILE"
rm "$CALLSPREFILE"

echo "# $POSTFILE"
cat "$POSTFILE"
