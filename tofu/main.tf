provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  res_prefix     = "EventsGate"
  log_group_name = "${local.res_prefix}/${var.eventbus_name}/watch"
  rule_name      = "${local.res_prefix}WatchBusRule"
  event_pattern = jsonencode({
    "account" = [data.aws_caller_identity.current.account_id]
  })
}


# Create CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "watch_events_log_group" {
  name              = local.log_group_name
  retention_in_days = var.retention_days
}

# Reference existing EventBridge Bus
data "aws_cloudwatch_event_bus" "target_bus" {
  name = var.eventbus_name
}

# Create EventBridge Rule
resource "aws_cloudwatch_event_rule" "all_events_rule" {
  name           = local.rule_name
  event_bus_name = data.aws_cloudwatch_event_bus.target_bus.name
  event_pattern  = local.event_pattern
}

# IAM Role for EventBridge to write to CloudWatch Logs
resource "aws_iam_role" "eventbridge_to_logs_role" {
  name = "${local.res_prefix}-eventbridge-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

# IAM Policy to allow writing to the log group
resource "aws_iam_policy" "eventbridge_to_logs_policy" {
  name        = "${local.res_prefix}-eventbridge-logs-policy"
  description = "Policy for EventBridge to write logs to CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = aws_cloudwatch_log_group.watch_events_log_group.arn
    }]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_eventbridge_logs_policy" {
  role       = aws_iam_role.eventbridge_to_logs_role.name
  policy_arn = aws_iam_policy.eventbridge_to_logs_policy.arn
}

# Add Target to EventBridge Rule
resource "aws_cloudwatch_event_target" "log_group_target" {
  rule           = aws_cloudwatch_event_rule.all_events_rule.name
  event_bus_name = data.aws_cloudwatch_event_bus.target_bus.name
  target_id      = "CloudWatchLogs"
  arn            = aws_cloudwatch_log_group.watch_events_log_group.arn
  role_arn       = aws_iam_role.eventbridge_to_logs_role.arn
}
