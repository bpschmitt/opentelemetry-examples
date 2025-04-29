[
  {
    "name": "python-otel-example",
    "image": "bschmitt769/otel-python-demo:0.2",
    "cpu": 256,
    "memoryReservation": 128,
    "portMappings": [
        {
            "containerPort": 8080,
            "hostPort": 8080,
            "protocol": "tcp"
        }
    ],
    "essential": true,
    "environment": [
        {
            "name": "OTEL_SERVICE_NAME",
            "value": "otel-python-rolldice-ecs"
        },
        {
            "name": "OTEL_PYTHON_LOG_FORMAT",
            "value": "{\"timestamp\": %(created)d, \"level\": \"%(levelname)s\",  \"trace.id\": \"%(otelTraceID)s\", \"span.id\": \"%(otelSpanID)s\", \"service.name\": \"%(otelServiceName)s\", \"message\": \"%(message)s\"}"
        },
        {
            "name": "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT",
            "value": "http://adot-lb-collectors.otel-demo:4317"
        },
        {
            "name": "OTEL_LOGS_EXPORTER",
            "value": "otlp"
        },
        {
            "name": "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED",
            "value": "true"
        },
        {
            "name": "OTEL_PYTHON_LOG_CORRELATION",
            "value": "true"
        },
        {
            "name": "OTEL_EXPORTER_OTLP_ENDPOINT",
            "value": "http://adot-lb-collectors.otel-demo:4317"
        }
    ],
    "mountPoints": [],
    "volumesFrom": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${demo_name}-python-otel-example",
            "awslogs-create-group": "True",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "systemControls": []
  }
]