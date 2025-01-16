output "airflow_broker_endpoint" {
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
  description = "The connection endpoint for the airflow broker Redis instance"
}
