#!/bin/sh

# $1 - path to a file with commands on each new line
A=`sed -n "${SGE_TASK_ID}p" < $1`

echo Running "$A"

eval $A
