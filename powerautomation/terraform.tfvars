region = "us-east-1"
client = "health"
pipeline = "cdr-pipeline"
environment = "preprod"
service = "power-automation"
lambda_execution_role_name = "lambda-execution"
account_id = "589118303122"

# AWS resources related variables

instancetype = "t3a.medium"
##################### values for SQS ######################

fifo_queue_status                  = true
content_based_deduplication_status = true
kms_data_key_reuse_period_seconds  = 300
message_retention_seconds          = 1209600
visibility_timeout_seconds         = 60
delay_seconds                      = 20
queue_names                        = ["adt", "mdm", "oru", "normalizer"]
#################### values for Kms Key ##########################

key_usage = "ENCRYPT_DECRYPT"
key_spec  = "SYMMETRIC_DEFAULT"

key_policy = <<EOF
{
"Version": "2012-10-17",
"Id": "key-consolepolicy-3",
"Statement": [
    {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::589118303122:root",
                "arn:aws:iam::161674638527:role/kpi-integration-builds",
                "arn:aws:iam::527774997072:root"
            ]
        },
        "Action": "kms:*",
        "Resource": "*"
    },
    {
        "Sid": "Allow use of the key",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::161674638527:root"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": "*"
    },
    {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::161674638527:root"
        },
        "Action": [
            "kms:CreateGrant",
            "kms:ListGrants",
            "kms:RevokeGrant"
        ],
        "Resource": "*",
        "Condition": {
            "Bool": {
                "kms:GrantIsForAWSResource": "true"
            }
        }
    }
 ]
}

EOF
################### values for s3 #######################

acl        = "private"
versioning = "Enabled"
s3_prefixes = [
  "adt/", "oru/", "lab/", "path/", "medications/", "phss/", "ccda/", "empi-consumer/", "ekg/", "rad/", "trans/"
]
################### values for ec2 #######################
ec2_resource_list = ["i-0e8c72721751253bc", "i-0b24237806367d974"]
cloudwatch_name = "test-alarms-lambda"