resource "aws_lambda_function" "trigger" {
  function_name = "trigger"
  description   = "Triggers an SQS event and an ECS task"
  handler       = "main.handler"
  runtime       = "nodejs12.x"

  role        = aws_iam_role.lambda_execution_role.arn
  memory_size = 128
  timeout     = 60

  source_code_hash = filebase64sha256("../trigger.zip")
  filename         = "../trigger.zip"

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.queue.id
      TASK_NAME = aws_ecs_task_definition.task-definition-test.family
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda,
  ]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/trigger"
  retention_in_days = 1
  tags              = {}
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

