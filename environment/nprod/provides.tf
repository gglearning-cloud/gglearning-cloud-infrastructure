# Provider

provider "aws" {
    region = "ap-south-1"
}

# Terraform Version

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.51.0"
    }
  }
  required_version = "> 1.8.0"
}

# State Locking
resource "aws_dynamodb_table" "tf_remote_state_locking" {
  hash_key = "LockID"
  name     = "terraform-s3-backend-locking"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode   = "PROVISIONED"
  write_capacity = 20
  read_capacity  = 20
}