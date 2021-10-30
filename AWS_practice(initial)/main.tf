provider "aws" {
    region = "us-east-1"
    access_key = "AKIA4WCN3RXZPH4OKYDC"
    secret_key = "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"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "-vpc"
    cidr = var.vpc_cidr_block

    azs             = [var.avail_zone]
    public_subnets  = [var.subnet_cidr_block]
    public_subnet_tags = { Name = "${var.env_prefix}-subnet-1" }

    tags = {
        Name = "${var.env_prefix}-vpc"
    }

}

module "webserver-instance" {
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    my_ip = var.my_ip
    subnet_id = module.vpc.public_subnets[0] 
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
}
