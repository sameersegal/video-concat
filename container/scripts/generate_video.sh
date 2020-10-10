#!/bin/bash

MOUNT=/tmp/workdir/scratch

# Copied url decoder from https://gist.github.com/cdown/1163649
urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

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
            --skip-download)           SKIP_DOWNLOAD=${VALUE} ;;     
            --skip-upload)             SKIP_UPLOAD=${VALUE} ;; 
            --delete-files)            DELETE_FILES=${VALUE} ;; 
            *)   
    esac    
done

echo "Check space #when new"
df -h 

# Downloading videos from the input folder
if [ -z "$SKIP_DOWNLOAD" ] || [ "$SKIP_DOWNLOAD" != "true" ]; 
then
    mkdir -p "${MOUNT}/$OUTPUT"
    cd "${MOUNT}/$OUTPUT"

    if [ -n "$DELETE_FILES" ];
    then
        DELETE_FILES=`urldecode "$DELETE_FILES"`
        echo $DELETE_FILES | xargs rm
        echo "DELETED files $DELETE_FILES"
    else        
        echo "Did NOT DELETE files"
    fi

    gdrive --service-account credentials.json download query "'$INPUT_FOLDER' in parents"  --skip
else
    cd "${MOUNT}/$OUTPUT"    

    if [ -n "$DELETE_FILES" ];
    then
        DELETE_FILES=`urldecode "$DELETE_FILES"`
        echo $DELETE_FILES | xargs rm
        echo "DELETED files $DELETE_FILES"
    else
        echo "Did NOT DELETE files"
    fi

    echo "Not downloading file based on flag $SKIP_DOWNLOAD"
fi

echo "Current Working Directory: $PWD"
ls -lrt

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

    echo "${arg1}|${arg2}|${arg3}|${arg4}|${arg5}|${arg6}"    

    # If the .ts file exists, we don't reprocess it
    # To reprocess, please delete the file using --delete-files
    if [[ -f "$i.ts" ]]; 
    then 
        echo "$i.ts FILE EXISTS. Not recreating"
    else
        # variable substitution into template. Remember if there is input &, it needs to be escaped \& otherwise sed treats & as a whole match
        t=`echo "$TEMPLATE" | sed 's@$i@'"$i"'@g' | sed 's@$arg1@'"$arg1"'@g' | sed 's@$arg2@'"$arg2"'@g' | sed 's@$arg3@'"$arg3"'@g' | sed 's@$arg4@'"$arg4"'@g' | sed 's@$arg5@'"$arg5"'@g' | sed 's@$arg6@'"$arg6"'@g'`
        echo "$t"
        eval "$t"
    fi    

    ((i=i+1))
 
done

# Close file descriptor
exec 3<&-

# echo "Check space #download before delete"
# df -h

# Creating space on the container as we are done with all the inputs
# if [ -z "$SKIP_DOWNLOAD" ] || [ "$SKIP_DOWNLOAD" != "true" ]; 
# then    
#     echo "Making space based on flag"
#     # find . -type f -not -name '*.ts' | xargs rm -rf
# else
#     echo "NOT making space based on flag"  
# fi

# echo "Check space #after delete"
# df -h

# The number of files that we need to concat. This will change if we are using intermediary files
concat_counter=$i
count=$i
# Max number of files to concat at a time
STEP=200
format=".ts"

# If there are too many inputs files to concat, we need to create intermediary files
if [[ $count -gt $STEP ]]; 
then
    echo "We need to break into loops"
    
    concat_counter=1    

    for ((i=1; i < count; i=i+STEP ));
    do
        start=$i
        end=$(( start+STEP > count ? count : start+STEP-1 ))
        # echo "$i,$start,$end"

        # Generate the concat command
        concatscript="concat:"
        for ((; start <= end; start++ ));
        do
            f="${start}${format}"
            if [[ -f "$f" ]]; then
                concatscript="${concatscript}${f}|"
            else
                echo "${f} is missing"    
            fi 
        done

        # Concat to intermediary file
        cmd=`echo "ffmpeg -i \"${concatscript}\" -q:a 0 -q:v 0 ${concat_counter}merged.ts"`
        echo "$cmd"
        eval "$cmd"

        ((concat_counter++))
    done

    # Changed format for the final concat
    format="merged.ts"
    echo "Now we need to concat $concat_counter files"
else
    echo "We DONT need to break into loops"
fi

# Generate concat command
final_concat_count=0
concatscript=""
for (( c=1; c<concat_counter; c++ ));
do
    f="${c}${format}"
    if [[ -f "$f" ]]; then
        concatscript="${concatscript} -i ${f}"
        ((final_concat_count++))
    else
        echo "${f} is missing"    
    fi    
done

# The final output name
d=`date +%d%h-%H%M.mp4`
file="$OUTPUT$d"

cmd=`echo "ffmpeg ${concatscript} -filter_complex \"concat=n=${final_concat_count}:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" $file"`
echo "$cmd"
eval "$cmd"

if [[ -f "$file" ]]; 
then 
    if [ -z "$SKIP_UPLOAD" ] || [ "$SKIP_UPLOAD" != "true" ];  then
        # Uploading to Output folder
        echo "Uploading file: $file"
        echo "gdrive --service-account credentials.json upload --parent $OUTPUT_FOLDER $file"
        gdrive --service-account credentials.json upload --parent $OUTPUT_FOLDER $file

        # cd ..
        # rm -rf temp
    else
        echo "Not uploading file based on flag $SKIP_UPLOAD"
        # cd ..
    fi
fi
