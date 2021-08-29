### PagerDuty Module
module "pagerduty" {
    source = "git@github.com:devopsidiot/terraform-modules.git//0.14/pagerduty"

  ### PagerDuty Inputs
    name               = "DevOps: OpsConsole-Postgres"     #FixMeLater
    escalation_policy  = "Escalation: DevOps Engineering"   #FixMeLater
    resolve_timeout    = 14400
    ack_timeout        = 600
    alert_creation     = "create_alerts_and_incidents"
    alert_grouping     = "intelligent"
  ### AWS SNS Topic Inputs
    service_name       = "Company-Postgres"             #Prefixed with "PagerDuty-DevOps-" in the module
  ### Slack Extension Inputs
    notify_resolve     = true
    notify_trigger     = true
    notify_escalate    = true
    notify_acknowledge = true
    notify_assignments = true
    notify_annotate    = true
    high_urgency       = true
    low_urgency        = true
    slack_channel      = "#devops-pagerduty"                #Required Input
    slack_channel_id   = ""                      #TODO# not sure if this can be a list
    token              = var.token                          #API Token for PagerDuty provider
}

### CloudWatch Alarms for Elasticsearch
resource "aws_cloudwatch_metric_alarm" "cluster_status_red" {
  count               = var.count_cluster_status_red ? 1 : 0
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-Red"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Average Elasticsearch cluster status is in red over last 1 minutes"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.es_domain_name
    ClientId   = var.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_yellow" {
  count               = var.count_cluster_status_yellow ? 1 : 0
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-Yellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Average elasticsearch cluster status is in yellow over last 1 minutes"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.es_domain_name
    ClientId   = var.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  count               = var.monitor_free_storage_space ? 1 : 0
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-Low-Disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Minimum"
  threshold           = max(10000, 0)
  alarm_description   = "Average Elasticsearch free storage space over last 5 minutes is too low"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.es_domain_name
    ClientId   = var.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  count               = var.monitor_blocked_index_writes ? 1 : 0
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-index-writes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch index writes being blocker over last 5 minutes"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.es_domain_name
    ClientId   = var.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "insufficient_available_nodes" {
  count               = var.monitor_insufficient_available_nodes ? 1 : 0
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-available-nodes"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "86400"
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Elasticsearch nodes minimum < 1 for 1 day"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.es_domain_name
    ClientId   = var.account_id
  }
}
