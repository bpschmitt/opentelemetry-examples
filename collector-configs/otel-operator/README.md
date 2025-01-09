# OTel Operator Example Files

## Pre-Requisites

Create the ServiceAccounts, ClusterRoles, and ClusterRoleBindings.  Modify before creating as needed.

```
kubectl create -f ta-sa.yaml
kubectl create -f ds-sa.yaml
```

## Install the OpenTelemetry Operator

```
helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator -f values.yaml -n otel-operator --create-namespace
```

## Install the OpenTelemetryCollector Custom Resources

```
kubectl create ns opentelemetry
kubectl apply -f ds-collector.yaml
kubectl apply -f ta-collector.yaml
```

## Install the Astro Shop Demo

```
helm upgrade --install astro-shop open-telemetry/opentelemetry-demo -f astro-shop-values.yaml -n opentelemetry-demo
```