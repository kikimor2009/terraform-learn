terraform {
  backend "s3" {
    encrypt = true
    bucket = "lock-mu-up"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "acg"
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "acg"
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "bucket" {
    bucket = "lock-mu-up"
    acl = "private"

    tags = {
        Name = "tf-state"
    }
}