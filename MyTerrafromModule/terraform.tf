terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  backend "s3" {
    bucket         = "via-terraform-state-bucket-2026"
    key            = "dev/module/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-terraform-state-dynameoDb-2026"
    encrypt        = true
  }
}
