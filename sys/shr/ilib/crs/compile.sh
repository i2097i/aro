#!/bin/sh

gcc -fPIC -c crs.c -o crs.o
gcc -shared -o libcrs.so crs.o
chmod +x libcrs.so
