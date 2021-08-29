### PagerDuty Module
module "pagerduty" {
    source = "git@github.com:devopsidiot/terraform-modules.git//0.14/pagerduty"

  ### PagerDuty Inputs
  name               = "DevOps: Company-EKS-prod" #FixMeLater
  escalation_policy  = "Escalation: DevOps Engineering" #FixMeLater
  resolve_timeout    = 14400
  ack_timeout        = 600
  alert_creation     = "create_alerts_and_incidents"
  alert_grouping     = "intelligent"
### AWS SNS Topic Inputs
  service_name            = "Company-EKS" #Prefixed with "PagerDuty-DevOps-" in the module
### Slack Extension Inputs
  notify_resolve     = true
  notify_trigger     = true
  notify_escalate    = true
  notify_acknowledge = true
  notify_assignments = true
  notify_annotate    = true
  high_urgency       = true
  low_urgency        = true
  slack_channel      = "#devops-pagerduty"
  slack_channel_id   = ""            #TODO# not sure if this can be a list
  token              = var.token                          #API Token for PagerDuty provider

}
### CloudWatch Alarms for EKS ContainerInsights (no module)
resource "aws_cloudwatch_metric_alarm" "cluster_node_cpu" {
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-node-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  threshold           = "70"
  alarm_description   = "Average CPU utilization of node"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"
  
  metric_query {
    id = "e1"
    return_data = "true"
    metric {
      namespace           = "ContainerInsights"
      period              = "60"
      stat                = "Average"
      metric_name         = "node_cpu_utilization"
      dimensions = {
        ClusterName = var.cluster_name
        
      }
   }
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_node_memory" {
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-node-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  threshold           = "70"
  alarm_description   = "Average Memory utilization of node"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"
  metric_query {
    id = "m1"
    return_data = "true"
    metric {
      namespace           = "ContainerInsights"
      period              = "60"
      stat                = "Average"
      metric_name         = "node_memory_utilization"
      dimensions = {
        ClusterName = var.cluster_name
        
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "cluster_pod_CPU" {
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-pod-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  threshold           = "70"
  alarm_description   = "Average CPU utilization of POD"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"
  
  metric_query {
    id = "m2"
    return_data = "true"
    metric {
      metric_name         = "pod_cpu_utilization"
      namespace           = "ContainerInsights"
      period              = "60"
      stat                = "Average"

      dimensions = {
        ClusterName = var.cluster_name
               
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "cluster_pod_memory" {
  alarm_name          = "${var.Brand}-${var.Team}-${var.Service}-pod-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  threshold           = "70"
  alarm_description   = "Average memory utilization of POD"
  alarm_actions       = [module.pagerduty.AWS_SNS_Topic_Arn]
  ok_actions          = [module.pagerduty.AWS_SNS_Topic_Arn]
  treat_missing_data  = "ignore"
  
  metric_query {
    id = "m2"
    return_data = "true"
    metric {
      metric_name         = "pod_memory_utilization"
      namespace           = "ContainerInsights"
      period              = "60"
      stat                = "Average"

      dimensions = {
        ClusterName = var.cluster_name
               
      }
    }
  }
}


