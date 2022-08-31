resource "aws_sns_topic" "kpi" {
  name = "${var.client}-${var.environment}"
}

resource "aws_sns_topic_policy" "kpi" {
  arn = aws_sns_topic.kpi.arn
  policy = data.aws_iam_policy_document.my_custom_sns_policy_document.json
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

resource "aws_cloudwatch_metric_alarm" "low_memory" {
  alarm_name          = "${var.client}-${var.environment}-low-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/Kafka"
  period              = "600"
  statistic           = "Average"
  threshold           = "75"
  datapoints_to_alarm       = "1
  alarm_description   = "Database instance memory above threshold"
  alarm_actions       = aws_sns_topic.kpi.arn

}
