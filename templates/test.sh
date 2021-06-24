#!/bin/bash

TEMPLATE_FILE=template
SEQUENCE_FILE=sequence.csv

# User provided ffmpeg command
TEMPLATE=`cat $TEMPLATE_FILE`

# A TSV file contains list of files and arguments for the ffmpeg command
# Using file descriptor to allow ffmpeg to pipe input/output
exec 3< "$SEQUENCE_FILE"

i=1
while IFS=$'\t' read -u 3 -r -a line
do
    # parse arguments from tsv
    arg1=${line[0]}
    arg2=${line[1]}
    arg3=${line[2]}
    arg4=${line[3]}
    arg5=${line[4]}
    arg6=${line[5]}
    arg7=${line[6]}
    arg8=${line[7]}
    arg9=${line[8]}
    arg10=${line[9]}

    echo "${arg1}|${arg2}|${arg3}|${arg4}|${arg5}|${arg6}|${arg7}|${arg8}|${arg9}|${arg10}"

    t=`echo "$TEMPLATE" | sed 's@$i@'"$i"'@g' | sed 's@$arg1@'"$arg1"'@g' | sed 's@$arg2@'"$arg2"'@g' | sed 's@$arg3@'"$arg3"'@g' | sed 's@$arg4@'"$arg4"'@g' | sed 's@$arg5@'"$arg5"'@g' | sed 's@$arg6@'"$arg6"'@g' | sed 's@$arg7@'"$arg7"'@g' | sed 's@$arg8@'"$arg8"'@g' | sed 's@$arg9@'"$arg9"'@g' | sed 's@$arg10@'"$arg10"'@g'`
    #echo "$t"
    #eval "$t"

    ((i=i+1))

done
