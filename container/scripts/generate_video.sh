#!/bin/bash

# set -e

# named argument parsing
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)    
    echo "$KEY,$VALUE"
    case "$KEY" in
            --input-folder)            INPUT_FOLDER=${VALUE} ;;
            --output-folder)           OUTPUT_FOLDER=${VALUE} ;;
            --template-file-name)      TEMPLATE_FILE=${VALUE} ;;
            --sequence-file-name)      SEQUENCE_FILE=${VALUE} ;;
            --output-file-prefix)      OUTPUT=${VALUE} ;;     
            *)   
    esac    
done

mkdir -p temp
cd temp

# Downloading videos from the input folder
gdrive --service-account credentials.json download query "'$INPUT_FOLDER' in parents" 

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

d=`date +%d%h-%H%M.mp4`
file="$OUTPUT$d"

cmd=`echo "ffmpeg -i \"${concatscript}\" -vcodec h264 -acodec $file"`
echo "$cmd"
eval "$cmd"

if [[ -f "$file" ]]; 
then 
    # Uploading to Output folder
    gdrive --service-account credentials.json upload --parent $OUTPUT_FOLDER $file
fi

cd ..
rm -rf temp
