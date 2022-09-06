resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "EC2 status check ${var.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "status check of EC2 instance"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  datapoints_to_alarm = "1"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
  alarm_actions = var.cw_sns_topic_arn != null ? [var.cw_sns_topic_arn] : []
}

resource "aws_cloudwatch_dashboard" "EC2_Dashboard" {
  dashboard_name = "EC2-Dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "explorer",
            "width": 24,
            "height": 15,
            "x": 0,
            "y": 0,
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Maximum"
                    }
                ],
                "aggregateBy": {
                    "key": "InstanceType",
                    "func": "MAX"
                },
                "labels": [
                    {
                        "key": "State",
                        "value": "running"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "bottom"
                    },
                    "view": "timeSeries",
                    "rowsPerPage": 8,
                    "widgetsPerRow": 2
                },
                "period": 60,
                "title": "Running EC2 Instances CPUUtilization"
            }
        }
    ]
}
EOF
}

resource "aws_cloudwatch_composite_alarm" "EC2" {
  alarm_description = "Composite alarm that monitors CPUUtilization "
  alarm_name        = "EC2_Composite_Alarm"
  alarm_actions = [aws_sns_topic.EC2_topic.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.EC2_CPU_Usage_Alarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.EBS_WriteOperations.alarm_name})"

  depends_on = [
    aws_cloudwatch_metric_alarm.EC2_CPU_Usage_Alarm,
    aws_sns_topic.EC2_topic,
    aws_sns_topic_subscription.EC2_Subscription
  ]
i}


# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_Alarm" {
# defining the name of AWS cloudwatch alarm
  alarm_name          = "EC2_CPU_Usage_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
# Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
# The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
# After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period = "60"
  statistic = "Average"
# CPU Utilization threshold is set to 10 percent
  threshold = "70"
alarm_description     = "This metric monitors ec2 cpu utilization exceeding 70%"


resource "aws_cloudwatch_log_group" "ebs_log_group" {
  name = "ebs_log_group"
  retention_in_days = 30
}


resource "aws_cloudwatch_log_stream" "ebs_log_stream" {
  name           = "ebs_log_stream"
  log_group_name = aws_cloudwatch_log_group.ebs_log_group.name
}


resource "aws_sns_topic" "EC2_topic" {
  name = "EC2_topic"
}

resource "aws_sns_topic_subscription" "EC2_Subscription" {
  topic_arn = aws_sns_topic.EC2_topic.arn
  protocol  = "email"
  endpoint  = "automateinfra@gmail.com"

  depends_on = [
    aws_sns_topic.EC2_topic
  ]
}

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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.kafka_clustername}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.kafka_clustername}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        ClusterName = "${var.kafka_clustername}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        ClusterName = "${var.es_domainname}"
        ClientId   = "${var.es_clientid}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
   dimensions = {
        ClusterName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.es_domainname}"
         ClientId   = "${var.es_clientid}"
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
  dimensions = {
        ClusterName = "${var.es_domainname}"
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
  period              = "600"
  statistic           = "Maximum"
  threshold           = "5000"
  datapoints_to_alarm   = "15"
  alarm_description   = "Database instance cluster Replica lag is greater"
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
        ClusterName = "${var.docdb_clustername}"
      }

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
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
        ClusterName = "${var.docdb_clustername}"
      }
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
  alarm_actions       = [aws_sns_topic.kpi.arn]
dimensions = {
        ClusterName = "${var.docdb_clustername}"
      }
}
