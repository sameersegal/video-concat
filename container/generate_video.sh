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
            --sequence-file-name)      SEQUENCE_FILE=${VALUE} ;;
            --output-file-prefix)      OUTPUT=${VALUE} ;;     
            *)   
    esac    
done

mkdir -p temp
cd temp

# Downloading videos from the input folder
gdrive --service-account credentials.json download query "'$INPUT_FOLDER' in parents" 

count=0
i=0
inputs=""
filter_complex=""
while IFS="" read -r p || [ -n "$p" ]
do
  #printf '%s\n' "$p"
  if [[ -f "$p" ]]
    then     
                  
        # Checking if it contains Audio and Video streams
        isAudio=`ffmpeg -i "$p" 2>&1 | grep Audio`
        isVideo=`ffmpeg -i "$p" 2>&1 | grep Video`

        arg=""
        if [ -n "$isAudio" ] && [ -n "$isVideo" ]; then
            arg="[$i:v] [$i:a]"
            filter_complex="$filter_complex $arg"
            ((count++))
            ((i++))

            inputs="$inputs -i \"$p\""
        elif [ -n isVideo ]; then
            arg="[$i:v]"     
            echo "$p does not have an audio stream"
        fi
        
    else
        echo "$p does not exist on your filesystem"        
    fi
done < $SEQUENCE_FILE

if [ -n "$inputs" ]; then
    # Generating the ffmpeg concat command
    cmd="ffmpeg $inputs"
    cmd="$cmd -filter_complex \"$filter_complex"
    cmd="$cmd concat=n=$count:v=1:a=1 [v] [a]\""
    cmd="$cmd -map \"[v]\" -map \"[a]\""
    cmd="$cmd raw.mp4"

    echo $cmd
    eval $cmd

    d=`date +%d%h-%H%M.mp4`
    file="$OUTPUT$d"

    # Creates a compressed video
    ffmpeg -i raw.mp4 -vcodec h264 -acodec aac $file

    # Uploading to Output folder
    gdrive --service-account credentials.json upload --parent $OUTPUT_FOLDER $file

else
    echo "No video file to process"
fi


cd ..
#rm -rf temp
