terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.34.0"
    }
  }
}

provider "aws" {

        region = "us-east-1"
}

module "myModule" {
  source             = "./GenModule"
  path_to_public_key = "modKey.pub"
  tags = {
   Name = "Terraform-Instance"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
  ec2_type      = "t2.small"
  block_storage = 10
  allowed_ports = [22, 80, 443, 5000]
  count_number  = 2
  
  s3_name = "via-terraform-state-bucket-2026"
  dynamodb_name = "my-terraform-state-dynameoDb-2026"
}

