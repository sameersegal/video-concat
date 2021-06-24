#!/bin/bash

TEMPLATE_FILE=template

# User provided ffmpeg command
TEMPLATE=`cat $TEMPLATE_FILE`

i=23
arg1=$1
arg2=$2
arg3=$3
arg4=$4
arg5=$5
arg6=$6
arg7=$7
arg8=$8
arg9=$9
arg10=$10

echo "${arg1}|${arg2}|${arg3}|${arg4}|${arg5}|${arg6}|${arg7}|${arg8}|${arg9}|${arg10}"

t=`echo "$TEMPLATE" | sed 's@$i@'"$i"'@g' | sed 's@$arg1@'"$arg1"'@g' | sed 's@$arg2@'"$arg2"'@g' | sed 's@$arg3@'"$arg3"'@g' | sed 's@$arg4@'"$arg4"'@g' | sed 's@$arg5@'"$arg5"'@g' | sed 's@$arg6@'"$arg6"'@g' | sed 's@$arg7@'"$arg7"'@g' | sed 's@$arg8@'"$arg8"'@g' | sed 's@$arg9@'"$arg9"'@g' | sed 's@$arg10@'"$arg10"'@g'`
echo "$t"
eval "$t"

