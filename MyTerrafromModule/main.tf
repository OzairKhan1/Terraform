module "myModule" {
  source = "git::https://github.com/OzairKhan1/Terraform.git//MyTerrafromModule/GenModule?ref=dev"
  environment  = var.environment
  project_name = var.project_name
  path_to_public_key = var.path_to_public_key
  ec2_type           = var.ec2_type
  block_storage      = var.block_storage
  allowed_ports      = var.allowed_ports
  count_number       = var.count_number

  tags = {
    Name        = "Demo Instance for ${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}
