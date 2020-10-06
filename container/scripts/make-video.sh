#!/bin/bash

# https://stackoverflow.com/questions/9393038/ssh-breaks-out-of-while-loop-in-bash
# https://bash.cyberciti.biz/guide/Reads_from_the_file_descriptor_(fd)

SEQUENCE_FILE=$1
TEMPLATE_FILE=$2

TEMPLATE=`cat $TEMPLATE_FILE`

exec 3< "$SEQUENCE_FILE"

i=1
while IFS=$'\t' read -u 3 -r -a line
do
 arg1=${line[0]}
 arg2=${line[1]}
 arg3=${line[2]}
 arg4=${line[3]}
 arg5=${line[4]}
 arg6=${line[5]}
 
 echo "${arg1}|${arg2}|${arg3}|${arg4}|${arg5}|${arg6}"
 rm "${i}.ts"

 t=`echo "$TEMPLATE" | sed 's@$i@'"$i"'@g' | sed 's@$arg1@'"$arg1"'@g' | sed 's@$arg2@'"$arg2"'@g' | sed 's@$arg3@'"$arg3"'@g' | sed 's@$arg4@'"$arg4"'@g' | sed 's@$arg5@'"$arg5"'@g' | sed 's@$arg6@'"$arg6"'@g'`
 eval "$t"

 ((i=i+1))
 
done

exec 3<&-

concatscript="concat:"
for (( c=1; c<i; c++ ));
do
    f="${c}.ts"
    if [[ -f "$f" ]]; then
        concatscript="${concatscript}${f}|"
    else
        echo "${f} is missing"    
    fi    
done

rm "out.mp4"
t=`echo "ffmpeg -i \"${concatscript}\" out.mp4"`
eval "$t"

