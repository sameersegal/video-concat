resource "aws_sqs_queue" "download" {
  name = "${var.sqs_queue_name}-download"
}

resource "aws_sqs_queue" "convert" {
  name = "${var.sqs_queue_name}-convert"
}

output "download_queue_url" {
  value = aws_sqs_queue.download.id
}

output "convert_queue_url" {
  value = aws_sqs_queue.convert.id
}
