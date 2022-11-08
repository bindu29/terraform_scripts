#################### Lambda Function #####################

# This is to create Lambda role and attaching the policies to it.

resource "aws_iam_role" "lambda_role" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-${var.lambda_execution_role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
     aws_iam_policy.s3_policy.arn,
     aws_iam_policy.sqs_policy.arn,
     aws_iam_policy.kms_policy.arn,
     aws_iam_policy.sns_policy.arn,
     aws_iam_policy.ec2_policy.arn,
  ]
}   

resource "aws_iam_policy" "s3_policy" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-s3-policy"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
         "Sid": "Stmt1652080810304",
         "Action": ["s3:PutObject", "s3:GetObjectAcl", "s3:GetObject", "s3:ListBucket", "s3:PutObjectAcl"]
         "Effect": "Allow",
         "Resource": "*"
        }
      ]
  })
}

resource "aws_iam_policy" "sqs_policy" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-sqs-policy"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
         "Sid": "Stmt1652081796170",
         "Action": [
           "sqs:GetQueueUrl",
           "sqs:SendMessage",
           "sqs:SendMessageBatch",
           ]
         "Effect": "Allow",
         "Resource": "*"
        }
      ]
  })
}

resource "aws_iam_policy" "kms_policy" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-kms-policy"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
         "Sid": "Stmt1652082214697",
         "Action": [
           "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:GetpublicKey",
            "kms:CreateGrant",
            "kms:ListAliases"
          ],
         "Effect": "Allow",
         "Resource": "*"
        }
      ]
  })
}
resource "aws_iam_policy" "sns_policy" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-sns-policy"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
         "Sid": "Stmt1652082214600",
         "Action": [
           "SNS:Subscribe",
           "SNS:SetTopicAttributes",
           "SNS:RemovePermission",
           "SNS:Receive",
           "SNS:Publish",
           "SNS:ListSubscriptionsByTopic",
           "SNS:GetTopicAttributes",
           "SNS:DeleteTopic",
           "SNS:AddPermission"
          ],
         "Effect": "Allow",
         "Resource": "*"
        }
      ]
  })
}
resource "aws_iam_policy" "ec2_policy" {
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-ec2-policy"
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
         "Sid": "Stmt1652082214600",
         "Action": [
           "ec2:GetPasswordData",
            "ec2:DescribeInstances",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:DescribeInstanceStatus"
          ],
         "Effect": "Allow",
         "Resource": "*"
        }
      ]
  })
}


# This is to create LambdaPermissions for s3 bucket and Bucket notification



resource "aws_lambda_permission" "allow-sns-to-lambda" {
  function_name = aws_lambda_function.lambda_powerautomation.arn
  action = "lambda:InvokeFunction"
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.kpi-lambda.arn
  statement_id = "AllowExecutionFromSNS"
}


# This is to create Lambda function

resource "aws_lambda_function" "lambda_powerautomation" {
  
  filename      = "lambda_function.zip"
  function_name = "kpi_${lower(var.environment)}_${lower(var.client)}-power-automation"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  architectures = [ "x86_64" ]
  timeout = 60
  package_type  = "Zip"
  kms_key_arn = aws_kms_key.kpi.arn
 
 

  source_code_hash = filebase64sha256("lambda_function.zip")
  
  environment {
    variables = {
      INSTANCE_MAPPING = jsonencode({"${var.cloudwatch_name}":"${var.ec2_resource_list}"})
  }
}
}