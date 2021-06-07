provider "aws" {
    region = ""
    access_key = ""
    secret_key = ""
}

variable subnet_cidr_block {
  type        = string
  default     = "10.0.1.0/24"
  description = "subnet cidr block"
}


resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        vpc-env = "dev"
        Name = "development"
    } 
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = ""
}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = ""
    availability_zone = ""
}

output dev-vpc {
  value = "aws_subnet.dev-subnet-2.id"
}
