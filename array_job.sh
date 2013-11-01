#!/bin/sh

usage()
{
	echo "Usage:"
	echo "$0 -l QUEUE [ -o OUTPUT_DIRECTORY ] [-e EMAIL] [ -O QUSB_OPTIONS] [-h] COMMAND_SCRIPT [COMMAND_SCRIPT_ARGS...]"
	cat <<EOF
Submits an array job executing a list of commands.

COMMAND_SCRIPT specifies the command script. The command script is expected
to output (to STDOUT) a list (separated by newlines) of commands to be ran
as an array job. It will be passed COMMAND_SCRIPT_ARGS if you specify them.

Arguments:
-e EMAIL
    Optional. If set, then then a sentinel job will be submitted to run
    after the array job is complete. It will notify you on this email
    when it finishes.
-h
    Optional. Print this message and quit.
-l QUEUE
    Mandatory. Specifies the cluster queue to submit the jobs to. 
-o OUTPUT_DIRECTORY
    Optional. Specifies the output directory. By default the current
    directory is used. The standard outputs/errors of the commands
    will be sent there.
-O QSUB_OPTIONS
    Optional. Use this to pass additional options to qsub (e.g. set the resource
    limits for each job).
EOF
	exit $1
}

output_directory="$(pwd)"
email=
queue=
qsub_options=

while getopts "O:o:l:e:h" opt; do
	case $opt in
	o ) output_directory=$OPTARG ;;
	O ) qsub_options=$OPTARG ;;
	l ) queue=$OPTARG ;;
	e ) email=$OPTARG ;;
	h ) usage 0 ;;
        \?) exit -1 ;;
        esac
done

if [ -z "$queue" ]
then
	echo "$0: missing -l QUEUE"
	exit -1
fi

shift $((OPTIND-1))

command_script="$@"

if [ -z "$command_script" ]
then
	echo "$0: missing COMMAND_SCRIPT [COMMAND_ARGS...]"
	exit -1
fi

mkdir -p "$output_directory"

cmd_file=`mktemp "$output_directory"/commands.XXXXXX`
temp_file=`mktemp`

eval "$command_script" > "$temp_file"

mv "$temp_file" "$cmd_file"

job_name="$output_directory.${cmd_file##*.}"

qsub $qsub_options -j yes -o "$output_directory" -N "$job_name" -cwd -l $queue -t 1-`wc -l < "$cmd_file"` `which array_runner.sh` "$cmd_file"

if [ -n "$email" ]
then
	qsub -m e -M $email -b y -j yes -o /dev/null -N "$job_name".sentinel -cwd -l $queue -hold_jid "$job_name" echo
fi
