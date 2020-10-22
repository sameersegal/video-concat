#!/bin/bash

region=${V_REGION}
queue=${V_QUEUE_URL}
MOUNT=${V_MOUNT}
s3_bucket=${V_BUCKET}

# Fetch messages and render them until the queue is drained.
while [ /bin/true ]; do
    # Fetch the next message and extract the S3 URL to fetch the POV-Ray source ZIP from.
    echo "Fetching messages fom SQS queue: ${queue}..."
    result=$( \
        aws sqs receive-message \
            --queue-url ${queue} \
            --region ${region} \
            --wait-time-seconds 5 \
            --query Messages[0].[Body,ReceiptHandle] \
        | sed -e 's/^"\(.*\)"$/\1/'\
    )

    echo "Received the following message"
    echo $result

    if [ -z "$result" ] || [ "$result" = "null" ] ; then
        echo "No messages left in queue. Exiting."
        exit 0
    else
        echo "Message: ${result}."

        receipt_handle=$(echo ${result} | sed -e 's/^.*"\([^"]*\)"\s*\]$/\1/')
        echo "Receipt handle: ${receipt_handle}."

        file=$(echo ${result} | sed -e 's/^.*\\"file\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "File: ${file}."  

        project=$(echo ${result} | sed -e 's/^.*\\"project\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Project: ${project}."        

        # if [ -n "$result" ] \
        # && [ -n "$receipt_handle" ] \
        # && [ -n "$input_folder" ] \
        # && [ -n "$output_folder" ] \
        # && [ -n "$sequence_file_name" ] \
        # && [ -n "$output_file_prefix" ]; then

        mkdir -p "${MOUNT}/$project/processed"
        cd "${MOUNT}/$project/processed"
        filename=$(basename -- "$file")
        time ffmpeg -hide_banner -i "../raw/$file" -c:a copy -c:v h264_nvenc -b:v 5M "${filename}.mp4"
        ffprobe -hide_banner -i "${filename}.mp4"
        aws s3 cp "${filename}.mp4" "s3://${s3_bucket}/$project/"
        cd "${MOUNT}"

        # Deleting the message from the queue to allow for
        # parallel builds
        echo "Deleting message..."
        aws sqs delete-message \
            --queue-url ${queue} \
            --region ${region} \
            --receipt-handle "${receipt_handle}"        

        # else
        #     echo "ERROR: Could not extract params from message from SQS message."
        # fi
    fi
done
