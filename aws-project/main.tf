provider "aws" {
    region = "us-east-1"
    access_key = "AKIA4WCN3RXZPH4OKYDC"
    secret_key = "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"
}

resource "aws_vpc" "lab-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "lab-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.lab-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

module "webserver-instance" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.lab-vpc.id
    my_ip = var.my_ip
    subnet_id = module.lab-subnet.subnet.id 
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
}
