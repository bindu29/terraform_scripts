########################################
# SNS
########################################
resource "aws_sns_topic" "kpi" {
  name = "${var.client}-${var.environment}"
   delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3
    },
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}


resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.kpi.arn
  protocol  = "email"
  endpoint  = "jsanthapuri@kpininja.com"
}
resource "aws_sns_topic_policy" "kpi" {
  arn = aws_sns_topic.kpi.arn
  policy = data.aws_iam_policy_document.kpi.json
}

data "aws_iam_policy_document" "kpi" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.kpi.arn,
    ]

    sid = "__default_statement_ID"
  }
}
########################################
# Cloudwatch for Kafka
########################################

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.client}-${var.environment}-kafka-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CpuSystem"
  namespace           = "AWS/Kafka"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_description   = "Database instance CPU above threshold"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        "Cluster Name" = "${var.kafka_clustername}"
         "Broker ID" =  "1"
      }
}

resource "aws_cloudwatch_metric_alarm" "kafka_disk" {
  alarm_name          = "${var.client}-${var.environment}-msk-datalogs-disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "KafkaDataLogsDiskUsed"
  namespace           = "AWS/Kafka"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "MSK Broker Data Logs Disk Usage"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        "Cluster Name" = "${var.kafka_clustername}"
      }
}
########################################
# Cloudwatch for Elasticsearch
########################################

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_red" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterStatusIsRed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "elasticsearch cluster status is in red"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        DomainName = "${var.es_domainname}"
        ClientId   = "${var.es_clientid}"
      }
}
resource "aws_cloudwatch_metric_alarm" "cluster_status_is_yellow" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterStatusIsYellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "elasticsearch cluster status is in yellow"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        DomainName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
      }
}
resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-FreeStorage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "Minimum free disk space on a single node"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        DomainName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
      }
}
resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterIndexWritesBlocked"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch index writes being blocker"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        DomainName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
      }
}
resource "aws_cloudwatch_metric_alarm" "insufficient_available_nodes" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-InsufficientAvailableNodes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "Insufficient available Elastic search nodes"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        DomainName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
      }
}
resource "aws_cloudwatch_metric_alarm" "ES_cpu" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-CPUUtilizationTooHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average elasticsearch cluster CPU utilization too high"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        DomainName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
      }
}
########################################
# Cloudwatch for DocumentDB
########################################
resource "aws_cloudwatch_metric_alarm" "ClusterReplicaLag" {
  alarm_name          = "${var.client}-${var.environment}-DocDB-low-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "15"
  metric_name         = "DBClusterReplicaLagMaximum"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "5000"
  datapoints_to_alarm   = "15"
  alarm_description   = "Database instance cluster Replica lag is greater"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
        DBClusterIdentifier = "${var.docdb_clustername}"
      }

}
resource "aws_cloudwatch_metric_alarm" "DOCDB_cpu" {
  alarm_name          = "${var.client}-${var.environment}-docdb-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_description   = "Database instance CPU above threshold"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
      DBClusterIdentifier = "${var.docdb_clustername}"
      }
}

resource "aws_cloudwatch_metric_alarm" "low_disk" {
  alarm_name          = "${var.client}-${var.environment}-docdb-low-disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeLocalStorage"
  namespace           = "AWS/DocDB"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1000000000"
  unit                = "Bytes"
  alarm_description   = "Database instance disk space is low"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
        DBClusterIdentifier = "${var.docdb_clustername}"
      }
}
