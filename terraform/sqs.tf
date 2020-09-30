resource "aws_sqs_queue" "queue" {
  name = var.sqs_queue_name
}
