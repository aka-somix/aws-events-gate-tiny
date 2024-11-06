output "log_group_name" {
  description = "Name of the CloudWatch Logs group."
  value       = aws_cloudwatch_log_group.watch_events_log_group.name
}

output "event_rule_name" {
  description = "Name of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.all_events_rule.name
}
