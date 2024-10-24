#S3 bucket
output "s3_bucket_arn" {
  value = aws_s3_bucket.tfstates
  description = "The ARN of the S3 bucket"
}
#DynamoDB
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform-state-lock.name
  description = "The name of the DynamoDB table"
}