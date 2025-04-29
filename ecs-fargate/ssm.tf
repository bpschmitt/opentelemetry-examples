resource "aws_ssm_parameter" "otel-collector-config" {
  name  = "${var.demo_name}-otel-collector-config"
  type  = "String"
  value = <<EOF
    # AWS System Mangager Parameter `AOT_CONFIG_CONTENT` Ref: https://aws-otel.github.io/docs/setup/ecs/config-through-ssm 
    # This file is only used with ADOTcollector as a sidecar in the Task Definitions 
    extensions:
      health_check:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      awsecscontainermetrics:
        collection_interval: 30s

    processors:
      cumulativetodelta:
      memory_limiter:
        check_interval: 1s
        limit_mib: 2000
      batch:
        send_batch_max_size: 1000
        timeout: 30s
        send_batch_size: 800
      resourcedetection:
        detectors:
          - env
          - system
          - ecs
          - ec2
      resource:
        attributes:
          - key: service.instance.id
            from_attribute: container.id
            action: insert
      # tail_sampling:
      #   decision_wait: 5s
      #   num_traces: 10000
      #   decision_cache:
      #     sampled_cache_size: 100_000
      #     non_sampled_cache_size: 100_000
      #   policies:
      #     [
      #       {
      #         name: trace-status-policy,
      #         type: status_code,
      #         status_code: { status_codes: [ERROR] }
      #       },
      #       {
      #         name: randomized-policy,
      #         type: probabilistic,
      #         probabilistic: { sampling_percentage: 50 },
      #       },
      #     ]

    exporters:
      otlphttp/newrelic:
        endpoint: https://otlp.nr-data.net:4317
        headers:
          api-key: ${var.newrelic_license_key}

    service:
      extensions: [health_check]
      telemetry:
        logs:
          level: "debug"
      pipelines:
        traces:
          receivers: [otlp]
          processors: [memory_limiter, batch]
          exporters: [otlphttp/newrelic]
        metrics:
          receivers: [awsecscontainermetrics, otlp]
          processors: [memory_limiter, resourcedetection, resource, cumulativetodelta, batch]
          exporters: [otlphttp/newrelic]
        logs:
          receivers: [otlp]
          processors: [memory_limiter, batch]
          exporters: [otlphttp/newrelic]
  EOF
}

resource "aws_ssm_parameter" "otel-lb-collector-config" {
  name  = "${var.demo_name}-otel-lb-collector-config"
  type  = "String"
  value = <<EOF
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317

  processors:

  exporters:
    debug:
      verbosity: basic
    loadbalancing:
      protocol:
        otlp:
          # all options from the OTLP exporter are supported
          # except the endpoint
          tls:
            insecure: true
          timeout: 1s
      resolver:
        dns:
          hostname: adot-collectors.otel-demo
          port: "4317"

  service:
    telemetry:
      logs:
        level: "debug"
    pipelines:
      traces:
        receivers:
          - otlp
        processors: []
        exporters:
          - loadbalancing
      logs:
        receivers:
          - otlp
        processors: []
        exporters:
          - loadbalancing
      metrics:
        receivers:
          - otlp
        processors: []
        exporters:
          - loadbalancing
  EOF
}