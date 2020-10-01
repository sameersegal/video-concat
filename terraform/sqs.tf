resource "aws_sqs_queue" "queue" {
  name = var.sqs_queue_name
}

output "queue_url" {
  value = aws_sqs_queue.queue.id
}