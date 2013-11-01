#!/bin/sh

queue=
email=

while getopts "l:e:" opt; do
	case $opt in
	l ) queue=$OPTARG ;;
	e ) email=$OPTARG ;;
	esac
done

if [ -z "$queue" ]
then
	echo "Usage: $0 -l QUEUE [-e EMAIL]"
	exit -1
fi

array_job.sh -l $queue -o example_output -e "$email" ./example_script.sh 10
