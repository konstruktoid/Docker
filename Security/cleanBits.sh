#!/bin/bash

for file in `find / -perm -02000`;
        do
			chmod -s $file
		done

for file in `find / -perm -04000`;
        do
			chmod -s $file
		done