[
  {
    "name": "aws-otel-collector",
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
            "valueFrom": "${demo_name}-otel-collector-config"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${demo_name}--otel-collector",
            "awslogs-create-group": "True",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "healthCheck": {
        "command": [
            "CMD",
            "/healthcheck"
        ],
        "interval": 10,
        "timeout": 5,
        "retries": 5,
        "startPeriod": 60
    },
    "systemControls": []
  }
]