#!/bin/bash
find / -perm -02000 -exec chmod -s {} +
find / -perm -04000 -exec chmod -s {} +