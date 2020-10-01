# Video Concat

With every family video, we get more ambitious. It always is a frantic finish just before we need to play the video. 

This project helps join/concatenate videos based on a sequence file. It get's triggered by API call and results in a final video published on Google Drive.

Video processing takes time (CPU intensive) and a lot of space. On Mac Air, you are severly constrained. That's why I picked AWS ECS with Fargate.

I have used Terraform to quickly bring up the infrastructure and destroy when I am done. It's perfect for infrequent use like Family events. 

We assume you have an account with AWS. We assume you have a brief understanding of AWS, Terraform, Docker, etc

## Get Started

1. Ensure you have the pre-requisites:
    1. AWS CLI downloaded and configured: `aws configure`
    2. Terraform downloaded
    3. Docker downloaded. On a Mac, `brew cask install docker` worked instead of the regular `brew install docker` 

2. Generate a Service Account to access Google Drive
    1. Follow the instructions [here](https://developers.google.com/identity/protocols/oauth2/service-account) to generate the json file and store it as `cotainer/credentials.json`
    2. Remember to enable Google Drive Apis for this service account.
    3. On the `output` Google Drive folder, remember to add the email of the Service Account as a collaborator with edit previleges. 

3. Build the infrastructure
    1. The following commands have to be run in the `terraform` folder
        ```
            cd terraform
        ```
    1. Create a `my.tfvars` file with the following:
        ```
            ecr_name                   = "ss-video-concate"
            ecs_cluster_name           = "ss-video-cluster"
            ecs_service_name           = "videoconcat-service"
            ecs_task_definition_family = "VideoConcat"
            docker_image               = "XXXXXXXXXX.dkr.ecr.ap-south-1.amazonaws.com/ss-video-concate"
            sqs_queue_name             = "video-queue"
        ```
        Note: You may note have the docker_image just yet. Put in a dummy value () and then update it after running the docker steps.

    2. Run terraform
        ```            
            terraform init
            terraform plan --var-file="my.tfvars" -out=tfplan
            terraform apply "tfplan"
        ```

    3. Note down the output variables from above
        ```
            base_url = "https://XXXXXXXX.execute-api.ap-south-1.amazonaws.com/test"
            queue_url = "https://sqs.ap-south-1.amazonaws.com/XXXXXXXXXXXX/video-queue"
        ```

3. Create and publish the docker image
    1. Create the docker image locally
        ```
            docker build -t video-concat .
        ```

    2. Follow the instructions on the ECR page to publish. It will substitute variables correctly.
        ```
            aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin XXXXXXXXXX.dkr.ecr.ap-south-1.amazonaws.com
            docker build -t ss-video-concate .
            docker tag ss-video-concate:latest XXXXXXXXXX.dkr.ecr.ap-south-1.amazonaws.com/ss-video-concate:latest
            docker push XXXXXXXXXX.dkr.ecr.ap-south-1.amazonaws.com/ss-video-concate:latest
        ```
    3. Copy the URI / ARN for the latest docker image and update the file `my.tfvars` created in step 3.2
    
4. And you are done! If you are stuck, keep repeating steps 3.1-3.3 to get the configuration right. 

5. Test your setup by creating a POST request to your API:

    1. Find the input and output folder IDs. It's part that comes after the *folders* in a Google Drive link
    ```
        https://drive.google.com/drive/folders/XXXXXXXXXXXXXgtj9wZG3HIcb6b1dLLqg
    ```
    
    2. Create a sequence file by mention each file name on a separate line. Remember that the sequence file should be a simple text file and not Google Docs or Doc or Docx or any other complex format. (We will be doing `cat sequence` in our script.)
    ```
        Opening.mp4    
        Video 1.mp4
        Video 2.mp4        
        Credits.mp4        
    ```
    
    3. Generate the video by calling the API:
    ```
        curl --location --request POST 'https://XXXXXXXX.execute-api.ap-south-1.amazonaws.com/test/video-concat/' \
            --header 'Content-Type: application/json' \
            --data-raw '{
                "input_folder": "XXXXXXXXXXTgtj9wZG3HIcb6b1dLLqg",
                "output_folder": "XXXXXXXXXjjLvduXwQM4j5lPHY7_6z6a",
                "sequence_file_name": "sequence",
                "output_file_prefix": "Short-Video-"
            }'
    ```
    4. Check CloudWatch logs to see if there are any errors in Lambda or ECS. If not, you will be your video. 

### How does this work?

![Architecture Diagram](./diagram.png)

1. User's `POST` request is passed on to a Lambda Function via API Gateway
2. The Lambda Function posts an event to SQS Queue and updates the ECS service's desired count to 1
3. The ECS container reads from the queue in a while loop, until there are no messages.
4. The ECS container downloads all the files in the `input` folder. It expects the sequence file to be present here.
5. It uses `ffmpeg` to concatenate the videos using [ffmpeg filters](https://ffmpeg.org/ffmpeg-filters.html#concat)
6. It then pushes the final video to the `output` folder
7. It then deletes the message from the queue, and checks for another message
