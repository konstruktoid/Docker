#!/bin/bash

for file in `find / -perm -02000`;
        do
                if test -e $file;
                        then chmod -s $file
                fi
        done

for file in `find / -perm -04000`;
        do
                if test -e $file;
                        then chmod -s $file
                fi
        done