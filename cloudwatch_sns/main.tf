########################################
# SNS
########################################
resource "aws_sns_topic" "kpi" {
  name = "${var.client}-${var.environment}"
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
resource "aws_cloudwatch_metric_alarm" "low_memory" {
  alarm_name          = "${var.client}-${var.environment}-kafkalow-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/Kafka"
  period              = "600"
  statistic           = "Average"
  threshold           = "75"
  datapoints_to_alarm       = "1"
  alarm_description   = "Database instance memory above threshold"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.kafka_clustername"
      }

}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.client}-${var.environment}-kafka-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Kafka"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_description   = "Database instance CPU above threshold"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.kafka_clustername"
      }
}

resource "aws_cloudwatch_metric_alarm" "low_disk" {
  alarm_name          = "${var.client}-${var.environment}-kafka-low-disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/Kafka"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1000000000"
  unit                = "Bytes"
  alarm_description   = "Database instance disk space is low"
  alarm_actions       = aws_sns_topic.kpi.arn
   dimensions = {
        ClusterName = "var.kafka_clustername"
      }
}
########################################
# Cloudwatch for Elasticsearch
########################################

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_red" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterStatusIsRed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "elasticsearch cluster status is in red"
  alarm_actions       = aws_sns_topic.kpi.arn
   dimensions = {
        ClusterName = "var.es_domainname"
        ClientId   = "var.es_clientid"
      }
}
resource "aws_cloudwatch_metric_alarm" "cluster_status_is_yellow" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterStatusIsYellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "elasticsearch cluster status is in yellow"
  alarm_actions       = aws_sns_topic.kpi.arn
   dimensions = {
        ClusterName = "var.es_domainname"
         ClientId   = "var.es_clientid"
      }
}
resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-FreeStorage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "Minimum free disk space on a single node"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.es_domainname"
         ClientId   = "var.es_clientid"
      }
}
resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-ClusterIndexWritesBlocked"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch index writes being blocker"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.es_domainname"
         ClientId   = "var.es_clientid"
      }
}
resource "aws_cloudwatch_metric_alarm" "insufficient_available_nodes" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-InsufficientAvailableNodes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "Insufficient available Elastic search nodes"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.es_domainname"
         ClientId   = "var.es_clientid"
      }
}
resource "aws_cloudwatch_metric_alarm" "high cpu" {
  alarm_name          = "${var.client}-${var.environment}-ElasticSearch-CPUUtilizationTooHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average elasticsearch cluster CPU utilization too high"
  alarm_actions       = aws_sns_topic.kpi.arn
  dimensions = {
        ClusterName = "var.es_domainname"
         ClientId   = "var.es_clientid"
      }
}
########################################
# Cloudwatch for DocumentDB
########################################
resource "aws_cloudwatch_metric_alarm" "ClusterReplicaLag" {
  alarm_name          = "${var.client}-${var.environment}-DocDB-low-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "DBClusterReplicaLagMaximum"
  namespace           = "AWS/DocDB"
  period              = "600"
  statistic           = "MAximum"
  threshold           = "5000"
  datapoints_to_alarm   = "15"
  alarm_description   = "Database instance cluster Replica lag is greater"
  alarm_actions       = aws_sns_topic.kpi.arn


}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.client}-${var.environment}-kafka-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DocDB"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "80"
  alarm_description   = "Database instance CPU above threshold"
  alarm_actions       = aws_sns_topic.kpi.arn

}

resource "aws_cloudwatch_metric_alarm" "low_disk" {
  alarm_name          = "${var.client}-${var.environment}-kafka-low-disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/DocDB"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1000000000"
  unit                = "Bytes"
  alarm_description   = "Database instance disk space is low"
  alarm_actions       = aws_sns_topic.kpi.arn

}
