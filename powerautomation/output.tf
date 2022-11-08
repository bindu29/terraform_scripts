# Get the ARN of the LambdaFunction as output

output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda_powerautomation.arn
}