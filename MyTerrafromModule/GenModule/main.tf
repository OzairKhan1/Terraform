# =========================
# locals.tf / inside module
# =========================
locals {
  default_tags = {
    type   = "General Resource"
    Module = "GenModule"
  }

  final_tags = merge(local.default_tags, var.tags)
}

# =========================
# Key Pair
# =========================
resource "aws_key_pair" "modKey" {
  key_name   = "modKey"
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
  name   = "General_Module-web-sg"
  vpc_id = aws_default_vpc.modVpc.id

  dynamic "ingress" {
    for_each = toset(var.allowed_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.final_tags
}

# =========================
# EC2 Instances
# =========================
resource "aws_instance" "modInstance" {
  count                  = var.count_number
  key_name               = aws_key_pair.modKey.key_name
  vpc_security_group_ids = [aws_security_group.modSg.id]
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_type

  root_block_device {
    volume_size = var.block_storage
    volume_type = "gp3"
    encrypted   = true
  }

  # ===== Name fix =====
  tags = merge(
    local.final_tags,
    {
      Name = "${lookup(local.final_tags, "Name", "Instance")}-${count.index + 1}"
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1

              apt update -y
              apt install nginx -y

              systemctl enable nginx
              systemctl start nginx

              echo "<h1>Welcome to my Personal Module 🚀</h1>" > /var/www/html/index.html
              echo "<p>Deployed using Terraform + user_data</p>" >> /var/www/html/index.html
              EOF
}
