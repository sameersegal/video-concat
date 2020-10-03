resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]
  tags = {}

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

}

resource "aws_ecs_cluster" "cluster2" {
  
    capacity_providers = [
        "FARGATE",
        "FARGATE_SPOT",
    ]

    name               = "ss-video-2"
    tags               = {}

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_service" "service2" {    
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 0
    enable_ecs_managed_tags            = false
    health_check_grace_period_seconds  = 0
    launch_type                        = "FARGATE"
    name                               = "ss-video-2-service"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    tags                               = {}
    task_definition                    = "VideoConcat:8"

    deployment_controller {
        type = "ECS"
    }

    network_configuration {
        assign_public_ip = true
        security_groups  = [
            "sg-08ea64fc68fd68f36",
        ]
        subnets          = [
            "subnet-0d6fd0eab8ba93a6e",
        ]
    }

    timeouts {}
}

resource "aws_ecs_task_definition" "task" {
  family = var.ecs_task_definition_family
  container_definitions = templatefile("container-definitions.json.tmpl", {
    docker_image   = var.docker_image
    log_group_name = aws_cloudwatch_log_group.log_group.name
    queue_url      = aws_sqs_queue.queue.id
    region         = "ap-south-1"
  })
  cpu                = "4096"
  execution_role_arn = aws_iam_role.execution_role.arn
  memory             = "8192"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  tags          = {}
  task_role_arn = aws_iam_role.task_role.arn
}

resource "aws_ecs_service" "service" {
  name                               = var.ecs_service_name
  cluster                            = aws_ecs_cluster.cluster.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 0
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 0
  #iam_role                           = "aws-service-role"
  #  #depends_on                         = ["aws-service-role"]
  launch_type = "FARGATE"

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  tags                = {}
  task_definition     = aws_ecs_task_definition.task.arn

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.simple.id,
    ]
    subnets = [
      aws_subnet.main.id,
    ]
  }

}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.ecs_log_group_name
  retention_in_days = 7
  tags              = {}
}