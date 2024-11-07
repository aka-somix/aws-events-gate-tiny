output "log_group_name" {
  description = "Name of the CloudWatch Logs group."
  value       = aws_cloudwatch_log_group.watch_events_log_group.name
}
