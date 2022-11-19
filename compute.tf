 data "aws_ami" "server_ami" {
  most_recent = true

  filter {
    name   = "name"
    /* values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] */
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20221103.3-x86_64-gp2*"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # amazon
}

resource "aws_instance" "terraform_test_ec2" {
  count         = var.ec2_count
  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  key_name      = var.key
  subnet_id     = aws_subnet.terraform_private_subnet[1].id //chamge as per requirement keep value either 0 or 1
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  tags = {
    Name = "terraform_test_ec2"
  }
    root_block_device {
    volume_size = var.vol_size
  }
  
}

resource "aws_instance" "terraform_test_ec2_public" {
  count         = var.ec2_count
  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  key_name      = var.key
  subnet_id     = aws_subnet.terraform_public_subnet[1].id //chamge as per requirement keep value either 0 or 1
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  tags = {
    Name = "terraform_test_ec2-public"
  }
    root_block_device {
    volume_size = var.vol_size
  }
  
}