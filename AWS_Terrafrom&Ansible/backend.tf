terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket  = "remotestate123443"
    key     = "terraformremotestate" #how the state file would be named
    profile = "acg"                  #which profile to use in aws , in case of multiple
    region  = "us-east-1"
  }
}