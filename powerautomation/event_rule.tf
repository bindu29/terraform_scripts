resource "aws_cloudwatch_event_rule" "kpi-rule" {
  name        = "kpi-rule"
  description = "Trigger Stop Instance every 5 min"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda-function" {
  rule      = aws_cloudwatch_event_rule.kpi-rule.name
  target_id = "sns"
  arn       = aws_sns_topic.kpi-lambda.arn
}

