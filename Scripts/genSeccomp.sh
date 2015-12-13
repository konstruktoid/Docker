#!/bin/sh
# Add the syscalls to be blocked to $DENY,
# outputs a file named seccomp-<date>.json
#
# https://filippo.io/linux-syscall-table/
# docker run -ti --security-opt seccomp:/file/path/seccomp-1512132157.json busybox sh

DENY="chroot mount umount ptrace"

date="$(date -u +%y%m%d%H%M)"
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
for call in $DENY; do
  echo "
        {
              'name': '$call',
              'action': 'SCMP_ACT_ERRNO'
         },"
done
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
