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

variable "docker_image" {
  type        = string
  description = "ARN of the docker image to be used"
}

