resource "aws_security_group" "lab-sg" {
    vpc_id = var.vpc_id
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

    subnet_id = var.subnet_id
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