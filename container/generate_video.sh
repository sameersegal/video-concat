#!/bin/bash

INPUT_FOLDER=$V_INPUT_FOLDER
OUTPUT_FOLDER=$V_OUTPUT_FOLDER
SEQUENCE_FILE=$V_SEQUENCE_FILE
OUTPUT=$V_OUTPUT_FILE_PREFIX

# # named argument parsing
# for ARGUMENT in "$@"
# do
#     KEY=$(echo $ARGUMENT | cut -f1 -d=)
#     VALUE=$(echo $ARGUMENT | cut -f2 -d=)    
#     echo "$KEY,$VALUE"
#     case "$KEY" in
#             --input-folder)          INPUT_FOLDER=${VALUE} ;;
#             --output-folder)         OUTPUT_FOLDER=${VALUE} ;;
#             --sequence)              SEQUENCE_FILE=${VALUE} ;;
#             --output)                OUTPUT=${VALUE} ;;     
#             *)   
#     esac    
# done

# Downloading videos from the input folder
gdrive --service-account credentials.json download query "'$INPUT_FOLDER' in parents" 

# Creating a sequence file with only files that are present
touch new_sequence
while IFS="" read -r p || [ -n "$p" ]
do
  #printf '%s\n' "$p"
  if [[ -f "$p" ]]
    then
        echo "$p exists on your filesystem."
        echo "$p" >> new_sequence
    fi
done < $SEQUENCE_FILE
SEQUENCE_FILE=new_sequence

count=`cat $SEQUENCE_FILE | wc -l`
inputs=`cat $SEQUENCE_FILE | awk '{print "-i \047" $0 "\047"}' | tr '\n' ' '`

# Deleting the updated sequence file
rm new_sequence

# Generating the ffmpeg concat command
cmd="ffmpeg $inputs"
cmd="$cmd -filter_complex "
cmd="$cmd \"[0:v] [0:a]"
for ((i=1;i<count;i++));
do
    cmd="$cmd [$i:v] [$i:a]"
done
cmd="$cmd concat=n=$count:v=1:a=1 [v] [a]\""
cmd="$cmd -map \"[v]\" -map \"[a]\""
cmd="$cmd raw.mp4"

# Generates the raw video
eval $cmd

d=`date +%d%h-%H%M.mp4`
file="$OUTPUT$d"

# Creates a compressed video
ffmpeg -i raw.mp4 -vcodec h264 -acodec aac $file

# Uploading to Output folder
gdrive --service-account credentials.json upload --parent $OUTPUT_FOLDER $file