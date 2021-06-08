provider "aws" {
    region = "us-east-1"
    access_key = "AKIA533VD6GOVJPUDYE3"
    secret_key = "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"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}



resource "aws_vpc" "lab-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "lab-subnet-1" {
    vpc_id = aws_vpc.lab-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_route_table" "lab-route-table" {
    vpc_id = aws_vpc.lab-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-rtbl"
    }
}

resource "aws_internet_gateway" "lab-igw" {
    vpc_id = aws_vpc.lab-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "aws-rtb-subnet" {
    subnet_id = aws_subnet.lab-subnet-1.id
    route_table_id = aws_route_table.lab-route-table.id
}

resource "aws_security_group" "lab-sg" {
    vpc_id = aws_vpc.lab-vpc.id
    name = "lab-sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-aws-linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

}

resource "aws_key_pair" "ssh-key" {
    key_name = "lab-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "lab-nginx" {
    ami = data.aws_ami.latest-aws-linux.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.lab-subnet-1.id
    vpc_security_group_ids = [aws_security_group.lab-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    /*user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y
                EOF
    */

    #user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}
