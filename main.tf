terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.65.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-${var.architecture}-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_file)
}

resource "aws_instance" "mcserver" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.id
  security_groups = [aws_security_group.mcserver.name]
  user_data = templatefile(
    "${path.module}/user_data.sh.tpl",
    {
      s3_bucket_prefix = var.bucket,
      server_jar_url   = var.server_jar_url,
    }
  )

  iam_instance_profile        = aws_iam_instance_profile.mcserver.id
  associate_public_ip_address = true

  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name = "minecraft-server"
  }
}

data "aws_vpc" "main" {
  default = true
}

resource "aws_security_group" "mcserver" {
  name        = "mcserver"
  description = "Allow MC inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "minecraft"
  }
}

data "aws_route53_zone" "primary" {
  name         = "${var.domain}."
  private_zone = false
}

resource "aws_route53_record" "mcserver" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mcserver.public_ip]
}
