# =========================
# Locals
# =========================
locals {

  name_prefix = "${var.project_name}-${var.environment}"

  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    Module      = "GenModule"
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
    CreatedAt   = timestamp()
  }

  final_tags = merge(local.default_tags, var.tags)
}

# =========================
# Key Pair
# =========================
resource "aws_key_pair" "modKey" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(var.path_to_public_key)
  tags       = local.final_tags
}

# =========================
# Default VPC
# =========================
resource "aws_default_vpc" "modVpc" {
  tags = local.final_tags
}

# =========================
# Security Group
# =========================
resource "aws_security_group" "modSg" {
  name   = "${local.name_prefix}-web-sg"
  vpc_id = aws_default_vpc.modVpc.id

  dynamic "ingress" {
    for_each = toset(var.allowed_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow port ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = local.final_tags
}

# =========================
# EC2 Instances
# =========================
resource "aws_instance" "modInstance" {

  count = var.count_number

  key_name               = aws_key_pair.modKey.key_name
  vpc_security_group_ids = [aws_security_group.modSg.id]
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_type

  root_block_device {
    volume_size = var.block_storage
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(
    local.final_tags,
    {
      Name = "${local.name_prefix}-instance-${count.index + 1}"
      Role = "WebServer"
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              apt update -y
              apt install nginx -y
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>${var.project_name} - ${var.environment} 🚀</h1>" > /var/www/html/index.html
              EOF
}
ubuntu@RachelGreen:~/terraform/Terraform/MyTerrafromModule/GenModule$ cat ~/terraform/Terraform_WorkSpaces/variables.tf 
variable "path_to_public_key" {
  description = "It is recommended to generate a Key and then Provide a path to Public Key only"
}

variable "ec2_ami_id" {
  description = "Provide you ami id. The default is ubuntu"
  default     = "ami-0b6c6ebed2801a5cb"
  type        = string
}

variable "ec2_type" {
  description = "Enter the type of instance that you want to Create. The default is t2.micro"
  default     = "t2.micro"
  type        = string
}

variable "block_storage" {
  type        = number
  description = "Just Provide volume for your ec2. The default is 8Gb"
  default     = 8
}

variable "tags" {
  description = "Custom tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "allowed_ports" {
  type        = list(number)
  description = "Add the Port number that is needed to open"
}



variable "count_number" {
  description = "Enter how many resource do you want to create. The default is 1"
  default     = 1
  type        = number

}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}
