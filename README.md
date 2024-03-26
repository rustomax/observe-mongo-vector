# observe-mongo-vector

Instructions on setting up ingest of self-managed mongodb metrics and logs into Observe (using vector agent)

## Background

Self-managed (installed on a Linux server) MongoDB database emits logs and metrics, which can be picked up and forwarded to Observe. In Observe, OPAL be applied to tranform incoming data into individual datasets, such as metrics, logs, SQL queries, etc.

## Configure vector agent to forward MongoDb logs and metrics to Observe

Here is a sample configuration of the vector agent to send data to Observe (in `/etc/vector/vector.yaml`):

```yaml
sources:
  mongo_metrics:
    type: mongodb_metrics
    endpoints:
      - mongodb://mongo-db-01:27017
  mongodb_logs:
    type: file
    include:
      - /var/log/mongodb/*.log

transforms:
  logs_transform:
    type: remap
    inputs:
      - mongodb_logs
    source: |-
      .tags.observe_env = "production"
      .tags.observe_host = "mongo-db-01"
      .tags.observe_datatype = "vector_logs"
  mongo_metrics_transform:
    type: remap
    inputs:
      - mongo_metrics
    source: |-
      .tags.observe_env = "production"
      .tags.observe_host = "mongo-db-01"
      .tags.observe_datatype = "vector_mongo_metrics"

sinks:
  observe_metrics:
    type: prometheus_remote_write
    inputs:
      - mongo_metrics_transform
    endpoint: >-
      https://{ CUSTOMER_ID }.collect.observeinc.com/v1/prometheus
    auth:
      strategy: bearer
      token: { METRICS_DATASTREAM_TOKEN }
    healthcheck: false
    request:
      retry_attempts: 5
  observe_logs:
    type: http
    inputs:
      - logs_transform
    encoding:
      codec: json
    uri: >-
      https://{ CUSTOMER_ID }.collect.observeinc.com/v1/http
    auth:
      strategy: bearer
      token: { LOGS_DATASTREAM_TOKEN }
```

> This is a partial configuration that only collects MongoDB logs and metrics. You are at liberty to add other sources, transforms and sinks as needed.

> For details on MongoDB metrics, check out [Vector MongoDB source documentation](https://vector.dev/docs/reference/configuration/sources/mongodb_metrics/)

> For details on Log collection, check out [Vector File source documentation](https://vector.dev/docs/reference/configuration/sources/file/)
