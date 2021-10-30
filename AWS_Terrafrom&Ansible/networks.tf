# Create VPC in master region (us-east-1)
resource "aws_vpc" "master-vpc" {
  provider             = aws.region-master
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "master-vpc-jenkins"
  }
}

# Create VPC in worker region (us-west-2)
resource "aws_vpc" "worker-vpc" {
  provider             = aws.region-worker
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

# Create IGW for master
resource "aws_internet_gateway" "master-igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.master-vpc.id
}

# Create IGW for worker
resource "aws_internet_gateway" "worker-igw" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.worker-vpc.id
}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "master_azs" {
  provider = aws.region-master
  state    = "available"
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "master-subnet-1" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.master-vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = element(data.aws_availability_zones.master_azs.names, 0)
}

#Create subnet # 2 in us-east-1
resource "aws_subnet" "master-subnet-2" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.master-vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = data.aws_availability_zones.master_azs.names[1]
}

#Create subnet in us-west-2 worker
resource "aws_subnet" "worker-subnet-1" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.worker-vpc.id
  cidr_block = "10.20.1.0/24"
}

#Initiate peering from master to worker
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  vpc_id      = aws_vpc.master-vpc.id
  peer_vpc_id = aws_vpc.worker-vpc.id
  peer_region = var.region-worker
  auto_accept = false
}

#Accept connection from master on worker side
resource "aws_vpc_peering_connection_accepter" "accept-peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true
}

#Create route table for master
resource "aws_route_table" "master_rt" {
  provider = aws.region-master
  vpc_id   = aws_vpc.master-vpc.id
  route {
    cidr_block = "0.0.0.0/0" #dest to the internet
    gateway_id = aws_internet_gateway.master-igw.id
  }
  route {
    cidr_block = "10.20.1.0/24" #dest to the worker subnet
    gateway_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-RT"
  }
}

#Overwrite the default route table for master
resource "aws_main_route_table_association" "set-master-default-rt" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.master-vpc.id
  route_table_id = aws_route_table.master_rt.id
}

#Create route table for worker
resource "aws_route_table" "worker_rt" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.worker-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  route {
    cidr_block = "10.10.1.0/24"
    gateway_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-RT"
  }
}

#Overwrite default route table for worker
resource "aws_main_route_table_association" "set-worker-default-rt" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.worker-vpc.id
  route_table_id = aws_route_table.worker_rt.id
}
