# Backend Config

terraform {
  backend "s3" {
    bucket  = "gglearning-aws-statefile"
    key     = "nprod/nonprod.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}