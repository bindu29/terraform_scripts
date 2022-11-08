# SNS
########################################
resource "aws_sns_topic" "kpi-lambda" {
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


resource "aws_sns_topic_subscription" "lambda-topic" {
  topic_arn = aws_sns_topic.kpi-lambda.arn
  protocol  = "email"
  endpoint  = "jsanthapuri@kpininja.com"
}
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.kpi-lambda.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_powerautomation.arn
}


resource "aws_sns_topic_policy" "kpi" {
  arn = aws_sns_topic.kpi-lambda.arn
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
      aws_sns_topic.kpi-lambda.arn,
    ]

    sid = "__default_statement_ID"
  }
}