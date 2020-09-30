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