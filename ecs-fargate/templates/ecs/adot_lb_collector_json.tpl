
[
  {
    "name": "aws-otel-lb-collector",
    "image": "amazon/aws-otel-collector",
    "cpu": 256,
    "memoryReservation": 128,
    "portMappings": [
        {
            "name": "aws-otel-collector-4317-tcp-grpc",
            "containerPort": 4317,
            "hostPort": 4317,
            "protocol": "tcp"
        },
        {
            "name": "aws-otel-collector-4318-tcp-http",
            "containerPort": 4318,
            "hostPort": 4318,
            "protocol": "tcp"
        }
    ],
    "essential": true,
    "environment": [],
    "mountPoints": [],
    "volumesFrom": [],
    "secrets": [
        {
            "name": "AOT_CONFIG_CONTENT",
            "valueFrom": "${demo_name}-otel-lb-collector-config"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${demo_name}--otel-lb-collector",
            "awslogs-create-group": "True",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "systemControls": []
  }
]