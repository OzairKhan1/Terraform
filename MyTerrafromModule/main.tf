# Either Put the values directly or provide values inside .tfvars which is industrial approach
module "myModule" {
  # The Module is called from Github Repo (main branch) 
  source = "git::https://github.com/OzairKhan1/Terraform.git//MyTerrafromModule/GenModule?ref=main"
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

