#!/bin/sh

# This file is released into the public domain

# $1 - number of jobs

for parameter in `seq 0 $1`
do
        echo "echo $parameter; sleep 60"
done
