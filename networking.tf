data "aws_availability_zones" "available"{}

resource "aws_vpc" "terraform_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform_test_vpc"
  }
    lifecycle {
    create_before_destroy = true
  }
}
//create public subnet
resource "aws_subnet" "terraform_public_subnet" {
  count                   = length(var.public_subnet)
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = var.public_subnet[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terraform_public subnet"
  }
}
//craete private subnet
resource "aws_subnet" "terraform_private_subnet" {
  count                   = length(var.private_subnet)
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = var.private_subnet[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terraform_private subnet"
  }
}
//provide the igw to vpc 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform_igw"
  }
}
//public route table added
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "terraform_public_route"
  }
}

//private route table added
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.terraform_vpc.id

  /* route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  } */


  tags = {
    Name = "terraform_private_route"
  }
}
//public route table association
resource "aws_route_table_association" "public_route" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.terraform_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_route.id
  lifecycle{
    create_before_destroy = true
  }
}
//private route table association
resource "aws_route_table_association" "private_route" {
  count          = length(var.private_subnet)
  subnet_id      = aws_subnet.terraform_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_route.id
  lifecycle{
    create_before_destroy = true
  }
}
//sg created
resource "aws_security_group" "terraform-sg" {
  name        = "terraform-sg-testing"
  description = "allow my public ip"
  vpc_id      = aws_vpc.terraform_vpc.id
}
//adding inbound sg 
resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.public_ip]
  security_group_id = aws_security_group.terraform-sg.id
}

resource "aws_security_group_rule" "ingress_self_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.terraform-sg.id
}

//outbound rule
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform-sg.id
}

resource "aws_vpc_endpoint" "ep-s3" {
  vpc_id        = aws_vpc.terraform_vpc.id
  service_name  = var.endpoint_service_name

  tags = {
    Environment = "terraform-test"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3-ep" {
  route_table_id  = aws_route_table.private_route.id
  vpc_endpoint_id = aws_vpc_endpoint.ep-s3.id
}