# Get S3 bucket ARN as output

output "aws_s3_bucket_ARN" {
  value = aws_s3_bucket.kpi.arn
}
 
# Get S3 bucket ID as output

output "aws_s3_bucket_ID" {
  value = aws_s3_bucket.kpi.id
}
