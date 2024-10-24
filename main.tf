#EC2 instance
resource "aws_instance" "Linux" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
}
#S3 bucket
resource "aws_s3_bucket" "tfstates" {
  bucket = "tfsatefiles"
  lifecycle {
    prevent_destroy = false
  }
}
#Enable bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tfstates.id
  versioning_configuration {
    status = "Enabled"
  }
}
#Eanable S3 bucket SSE
resource "aws_s3_bucket_server_side_encryption_configuration" "S3_Bucket" {
  bucket = aws_s3_bucket.tfstates.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "access" {
  bucket                  = aws_s3_bucket.tfstates.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#Create DynamoDB for Terraform state locking
resource "aws_dynamodb_table" "terraform-state-lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
#S3 Backend
terraform {
  backend "s3" {
    bucket         = "tfsatefiles"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}