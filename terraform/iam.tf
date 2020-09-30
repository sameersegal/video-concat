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
        },
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
