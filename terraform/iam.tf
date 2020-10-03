resource "aws_iam_role" "task_role" {
  name = "ECSRole"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )

  description           = "Allows ECS tasks to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600

  path = "/"
  tags = {}
}

resource "aws_iam_role" "execution_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2008-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "ecsTaskExecutionRole"
  path                  = "/"
  tags                  = {}

}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "task_execution_policy"
  path        = "/"
  description = "IAM policy for the task - SQS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [    
    {
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.queue.arn}"
   }   
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
      Version = "2008-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "lambdaExecutionRole"
  path                  = "/"
  tags                  = {}

}

