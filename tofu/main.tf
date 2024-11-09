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

  tags = merge(var.tags, { "Project" : "EventsGate" })
}

# Reference existing EventBridge Bus
data "aws_cloudwatch_event_bus" "target_bus" {
  name = var.eventbus_name
}


# Create CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "watch_events_log_group" {
  name              = local.log_group_name
  retention_in_days = var.retention_days
  tags              = local.tags
}

# Create a Log Policy to allow Cloudwatch to Create log streams and put logs
resource "aws_cloudwatch_log_resource_policy" "watch_events" {
  policy_name = "${local.res_prefix}-allow-logs-${data.aws_caller_identity.current.account_id}"
  policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "EventsGateLogsFromEventbridge${var.eventbus_name}",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "events.amazonaws.com"
          ]
        },
        "Action" : [
          "logs:*"
        ],
        "Resource" : "${aws_cloudwatch_log_group.watch_events_log_group.arn}:*"
      }
    ]
  })
}

# Create EventBridge Rule
resource "aws_cloudwatch_event_rule" "all_events_rule" {
  name           = local.rule_name
  event_bus_name = data.aws_cloudwatch_event_bus.target_bus.name
  event_pattern  = local.event_pattern
  tags           = local.tags
}

# Add Target to EventBridge Rule
resource "aws_cloudwatch_event_target" "log_group_target" {
  rule           = aws_cloudwatch_event_rule.all_events_rule.name
  event_bus_name = data.aws_cloudwatch_event_bus.target_bus.name
  target_id      = "CloudWatchLogs"
  arn            = aws_cloudwatch_log_group.watch_events_log_group.arn
}
