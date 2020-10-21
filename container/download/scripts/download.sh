#!/bin/bash

region=${V_REGION}
queue=${V_QUEUE_URL}
MOUNT=${V_MOUNT}

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

        input_folder=$(echo ${result} | sed -e 's/^.*\\"input_folder\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Input Folder: ${input_folder}."

        output_folder=$(echo ${result} | sed -e 's/^.*\\"output_folder\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Output Folder: ${output_folder}."

        sequence_file_name=$(echo ${result} | sed -e 's/^.*\\"sequence_file_name\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Sequence File Name: ${sequence_file_name}."

        template_file_name=$(echo ${result} | sed -e 's/^.*\\"template_file_name\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Template File Name: ${template_file_name}."

        output_file_prefix=$(echo ${result} | sed -e 's/^.*\\"output_file_prefix\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Output File Prefix: ${output_file_prefix}."

        skip_download=$(echo ${result} | sed -e 's/^.*\\"skip_download\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Delete Files: ${skip_download}."
        
        delete_files=$(echo ${result} | sed -e 's/^.*\\"delete_files\\":\s*\\"\([^\\]*\)\\".*$/\1/')
        echo "Delete Files: ${delete_files}."

        # if [ -n "$result" ] \
        # && [ -n "$receipt_handle" ] \
        # && [ -n "$input_folder" ] \
        # && [ -n "$output_folder" ] \
        # && [ -n "$sequence_file_name" ] \
        # && [ -n "$output_file_prefix" ]; then

        # if [ -z "$SKIP_DOWNLOAD" ] || [ "$SKIP_DOWNLOAD" != "true" ]; 
        # then
        #     mkdir -p "${MOUNT}/$OUTPUT"
        #     cd "${MOUNT}/$OUTPUT"

        #     if [ -n "$DELETE_FILES" ];
        #     then
        #         DELETE_FILES=`urldecode "$DELETE_FILES"`
        #         echo $DELETE_FILES | xargs rm
        #         echo "DELETED files $DELETE_FILES"
        #     else        
        #         echo "Did NOT DELETE files"
        #     fi
        
        mkdir -p "${MOUNT}/$output_folder/raw"
        cd "${MOUNT}/$output_folder/raw"
        gdrive --service-account credentials.json download query "'$input_folder' in parents"  --skip
        cd "${MOUNT}"

        # else
        #     cd "${MOUNT}/$OUTPUT"    

        #     if [ -n "$DELETE_FILES" ];
        #     then
        #         DELETE_FILES=`urldecode "$DELETE_FILES"`
        #         echo $DELETE_FILES | xargs rm
        #         echo "DELETED files $DELETE_FILES"
        #     else
        #         echo "Did NOT DELETE files"
        #     fi

        #     echo "Not downloading file based on flag $SKIP_DOWNLOAD"
        # fi

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
