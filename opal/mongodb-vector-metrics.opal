filter OBSERVATION_KIND = "prometheus" and string(EXTRA.observe_datatype) = "vector_mongo_metrics"
make_col 
    metric:string(EXTRA.__name__),
    endpoint:string(EXTRA.endpoint),
    engine:string(EXTRA.engine),
    host:string(EXTRA.host),
    tags:string(EXTRA.micros),
    mode:string(EXTRA.mode),
    observe_env:string(EXTRA.observe_env),
    observe_host:string(EXTRA.observe_host),
    state:string(EXTRA.state),
    type:string(EXTRA.type)
    
make_col 
    timestamp:timestamp_ms(int64(FIELDS.timestamp)),
    value:float64(FIELDS.value)

make_col tags:if(not is_null(tags), make_object(le:tags), make_object())

filter not is_null(metric) and not is_null(value) and value < float64("inf")
set_valid_from options(max_time_diff:duration_hr(4)), timestamp

// https://vector.dev/docs/reference/configuration/sources/mongodb_metrics/
make_col metricType:case(
    contains(metric, "asserts_total"), "cumulativeCounter",
    contains(metric, "bson_parse_error_total"), "cumulativeCounter",
    contains(metric, "connections"), "gauge",
    contains(metric, "extra_info_heap_usage_bytes"), "gauge",
    contains(metric, "extra_info_page_faults"), "gauge",
    contains(metric, "instance_local_time"), "gauge",
    contains(metric, "instance_uptime_estimate_seconds_total"), "gauge",
    contains(metric, "instance_uptime_seconds_total"), "gauge",
    contains(metric, "memory"), "gauge",
    contains(metric, "mongod_global_lock_active_clients"), "gauge",
    contains(metric, "mongod_global_lock_current_queue"), "gauge",
    contains(metric, "mongod_global_lock_total_time_seconds"), "cumulativeCounter",
    contains(metric, "mongod_locks_time_acquiring_global_seconds_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_cursor_open"), "gauge",
    contains(metric, "mongod_metrics_cursor_timed_out_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_document_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_get_last_error_wtime_num"), "gauge",
    contains(metric, "mongod_metrics_get_last_error_wtime_seconds_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_get_last_error_wtimeouts_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_operation_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_query_executor_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_record_moves_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_apply_batches_num_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_apply_batches_seconds_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_apply_ops_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_buffer_count"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_buffer_max_size_bytes_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_buffer_size_bytes"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_executor_queue"), "gauge",
    contains(metric, "mongod_metrics_repl_executor_unsignaled_events"), "gauge",
    contains(metric, "mongod_metrics_repl_network_bytes_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_network_getmores_num_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_network_getmores_seconds_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_network_ops_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_repl_network_readers_created_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_ttl_deleted_documents_total"), "cumulativeCounter",
    contains(metric, "mongod_metrics_ttl_passes_total"), "cumulativeCounter",
    contains(metric, "mongod_op_latencies_histogram"), "gauge",
    contains(metric, "mongod_op_latencies_latency"), "gauge",
    contains(metric, "mongod_op_latencies_ops_total"), "gauge",
    contains(metric, "mongod_storage_engine"), "gauge",
    contains(metric, "mongod_wiredtiger_blockmanager_blocks_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_blockmanager_bytes_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_cache_bytes"), "gauge",
    contains(metric, "mongod_wiredtiger_cache_bytes_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_cache_evicted_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_cache_max_bytes"), "gauge",
    contains(metric, "mongod_wiredtiger_cache_overhead_percent"), "gauge",
    contains(metric, "mongod_wiredtiger_cache_pages"), "gauge",
    contains(metric, "mongod_wiredtiger_cache_pages_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_concurrent_transactions_available_tickets"), "gauge",
    contains(metric, "mongod_wiredtiger_concurrent_transactions_out_tickets"), "gauge",
    contains(metric, "mongod_wiredtiger_concurrent_transactions_total_tickets"), "gauge",
    contains(metric, "mongod_wiredtiger_log_bytes_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_log_operations_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_log_records_scanned_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_log_records_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_session_open_sessions"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_transactions_checkpoint_seconds"), "gauge",
    contains(metric, "mongod_wiredtiger_transactions_checkpoint_seconds_total"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_transactions_running_checkpoints"), "cumulativeCounter",
    contains(metric, "mongod_wiredtiger_transactions_total"), "cumulativeCounter",
    contains(metric, "mongodb_op_counters_repl_total"), "cumulativeCounter",
    contains(metric, "mongodb_op_counters_total"), "cumulativeCounter",
    contains(metric, "network_bytes_total"), "cumulativeCounter",
    contains(metric, "network_metrics_num_requests_total"), "cumulativeCounter",
    contains(metric, "up"), "gauge",
    true, "gauge"
)

make_col unit: case(
  contains(metric, "seconds"), "seconds",
  contains(metric, "bytes"), "bytes"
)

pick_col 
    timestamp, metric, value, metricType, endpoint, engine, host, tags, 
    mode, observe_env, observe_host, state, type, unit

interface "metric",  metricType: type, metricUnit: unit
