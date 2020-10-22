resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
  tags = {}

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

}

resource "aws_ecs_task_definition" "download" {
  family = var.ecs_task_definition_family
  container_definitions = templatefile("download-container-definitions.json.tmpl", {
    docker_image   = "${aws_ecr_repository.download.repository_url}:latest"
    log_group_name = aws_cloudwatch_log_group.log_group.name
    queue_url      = aws_sqs_queue.download.id
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

  volume {
    name = "scratch-storage"
    # host_path = "/tmp/workdir/scratch"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.scratch.id
      # root_directory          = "/"
      transit_encryption = "ENABLED"
      # transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.scratch.id
        #   iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_task_definition" "convert" {
  family = "${var.ecs_task_definition_family}-convert"
  container_definitions = templatefile("convert-container-definitions.json.tmpl", {
    docker_image   = "${aws_ecr_repository.convert.repository_url}:latest"
    log_group_name = aws_cloudwatch_log_group.log_group.name
    queue_url      = aws_sqs_queue.convert.id
    bucket         = aws_s3_bucket.bucket.bucket
    region         = "ap-south-1"
  })
  cpu                = "4096"
  execution_role_arn = aws_iam_role.execution_role.arn
  memory             = "8192"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "EC2",
  ]
  tags          = {}
  task_role_arn = aws_iam_role.task_role.arn

  volume {
    name = "scratch-storage"
    # host_path = "/tmp/workdir/scratch"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.scratch.id
      # root_directory          = "/"
      transit_encryption = "ENABLED"
      # transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.scratch.id
        #   iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "service" {
  name                               = var.ecs_service_name
  cluster                            = aws_ecs_cluster.cluster.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 0
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 0
  launch_type                        = "FARGATE"

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  tags                = {}
  task_definition     = aws_ecs_task_definition.download.arn

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

resource "aws_ecs_service" "convert-service" {
  name                               = "${var.ecs_service_name}-convert"
  cluster                            = aws_ecs_cluster.cluster.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 0
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 0
  launch_type                        = "EC2"

  # platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  tags                = {}
  task_definition     = aws_ecs_task_definition.convert.arn

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    # assign_public_ip = true
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
  retention_in_days = 1
  tags              = {}
}
