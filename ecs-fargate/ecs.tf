# ecs.tf

resource "aws_ecs_cluster" "main" {
    name = "${var.demo_name}-cluster"
}

# OTel Collector
resource "aws_ecs_task_definition" "otel_collector" {
    family                   = "${var.demo_name}-otel-collector-task"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = templatefile("./templates/ecs/adot_collector_json.tpl", 
    {
        # app_image      = var.app_image
        # app_port       = var.app_port
        demo_name      = var.demo_name
        fargate_cpu    = var.fargate_cpu
        fargate_memory = var.fargate_memory
        aws_region     = var.aws_region
    })
}

# OTel LB Collector
resource "aws_ecs_task_definition" "otel_lb_collector" {
    family                   = "${var.demo_name}-otel-lb-collector-task"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = templatefile("./templates/ecs/adot_lb_collector_json.tpl", 
    {
        # app_image      = var.app_image
        # app_port       = var.app_port
        demo_name      = var.demo_name
        fargate_cpu    = var.fargate_cpu
        fargate_memory = var.fargate_memory
        aws_region     = var.aws_region
    })
}

# Python App
resource "aws_ecs_task_definition" "python_app" {
    family                   = "${var.demo_name}-python-app-task"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = templatefile("./templates/ecs/python_app_json.tpl", 
    {
        app_image      = var.app_image
        demo_name      = var.demo_name
        fargate_cpu    = var.fargate_cpu
        fargate_memory = var.fargate_memory
        aws_region     = var.aws_region
    })
}

# resource "aws_ecs_task_definition" "app" {
#     family                   = "${var.demo_name}-app-task"
#     execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#     network_mode             = "awsvpc"
#     requires_compatibilities = ["FARGATE"]
#     cpu                      = var.fargate_cpu
#     memory                   = var.fargate_memory
#     container_definitions    = templatefile("./templates/ecs/cb_app.json.tpl", 
#     {
#         app_image      = var.app_image
#         app_port       = var.app_port
#         fargate_cpu    = var.fargate_cpu
#         fargate_memory = var.fargate_memory
#         aws_region     = var.aws_region
#     })
# }

resource "aws_ecs_service" "otel_collector" {
    name            = "aws-otel-collector"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.otel_collector.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"
    
    service_registries {
        registry_arn = aws_service_discovery_service.adot-collectors.arn
    }

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    # load_balancer {
    #     target_group_arn = aws_alb_target_group.app.id
    #     container_name   = "aws-otel-collector"
    #     container_port   = var.app_port
    # }

    depends_on = [aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}

resource "aws_ecs_service" "otel_lb_collector" {
    name            = "aws-otel-lb-collector"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.otel_lb_collector.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    service_registries {
        registry_arn = aws_service_discovery_service.adot-lb-collectors.arn
    }

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    # load_balancer {
    #     target_group_arn = aws_alb_target_group.app.id
    #     container_name   = "aws-otel-lb-collectorr"
    #     container_port   = var.app_port
    # }

    depends_on = [aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}

resource "aws_ecs_service" "python_app" {
    name            = "python-otel-example"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.python_app.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.app.id
        container_name   = "python-otel-example"
        container_port   = var.app_port
    }

    depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}

## Service Discovery
resource "aws_service_discovery_private_dns_namespace" "otel" {
  name        = "otel-demo"
  description = "OpenTelemetry namespace"
  vpc = aws_vpc.main.id
}

resource "aws_service_discovery_service" "adot-collectors" {
  name = "adot-collectors"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
    health_check_custom_config {
      failure_threshold = 1
    }
}

resource "aws_service_discovery_service" "adot-lb-collectors" {
  name = "adot-lb-collectors"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
    health_check_custom_config {
      failure_threshold = 1
    }
}
