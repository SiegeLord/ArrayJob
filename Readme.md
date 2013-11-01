A simple script to simplify using array jobs with the SunGrid cluster system.

Example usage:
==============

~~~bash
array_job.sh -l my_queue -o example_output -e "my_email" ./example_script.sh 10
~~~ 

Where `example_script.sh` can look something like this:

~~~bash
#!/bin/sh

# $1 - number of jobs

for parameter in `seq 0 $1`
do
        echo "echo $parameter; sleep 60"
done
~~~

Installation:
=============

Copy both `array_job.sh` and `array_runner.sh` into your `PATH`.
