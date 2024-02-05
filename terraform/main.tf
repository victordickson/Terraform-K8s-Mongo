terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


# Used to get access to the effective account and user that Terraform
# is running as. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "database" {
  name        = "database-security-group"
  description = "Allow MongoDB traffic"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_private_subnet1_cidr
    ]
    description = "Ingress from VPC over MongoDB port 27017"
  }

  egress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_private_subnet1_cidr
    ]
  }

  egress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
    description  = "Egress HTTP to ALL over port 80"
  }

  egress {
    from_port    = 443
    to_port      = 443
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
    description  = "Egress HTTPS to ALL over port 443"
  }

  egress {
  from_port   = 27017
  to_port     = 27017
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Egress to MongoDB servers over port 27017"
}

  # SSH from Bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  tags = tomap(merge(var.mongo_tags, {"Name" = format("%s", var.mongo_app_sg_name)}))

}


resource "aws_instance" "mongo_instance" {
  ami           = var.ami_id  # Specify a MongoDB compatible AMI
  instance_type = "t2.micro"     

  key_name = var.ec2_key_name  
  subnet_id = aws_subnet.private_subnet1.id  # Specify the private subnet ID

  vpc_security_group_ids = [aws_security_group.database.id]                                                         
  

  tags = {
    Name = "MongoDB_Instance"
  }

  depends_on = [
    aws_security_group.database,
  ]

}

resource "aws_ebs_volume" "mongo_ebs_volume" {
  availability_zone = "${var.aws_region}a"
  size              = 1
}

resource "aws_volume_attachment" "mongo_attachment" {
  device_name = "/dev/sdf"  
  volume_id   = aws_ebs_volume.mongo_ebs_volume.id
  instance_id = aws_instance.mongo_instance.id
}
