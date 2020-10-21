variable "ecr_name" {
  type        = string
  description = "Elastic Container Repository Name"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Elastic Container Service Cluster Name"
}

variable "ecs_service_name" {
  type        = string
  description = "Elastic Container Service Service Name"
}

variable "ecs_task_definition_family" {
  type        = string
  description = "Elastic Container Service Task Definition Family"
}

# variable "docker_image" {
#   type        = string
#   description = "ARN of the docker image to be used"
# }

variable "sqs_queue_name" {
  type        = string
  description = "SQS queue name"
}

variable "api_path" {
  type        = string
  description = "API path"
}

variable "ecs_log_group_name" {
  type        = string
  description = "ECS log group name"
}

variable "sg_name" {
  type        = string
  description = "Security Group name"
}
