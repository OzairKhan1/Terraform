environment  = "stage"
project_name = "CBSI-PROJECT"
path_to_public_key = "/home/ubuntu/terraform/modKey.pub"
ec2_type           = "t2.micro"
block_storage      = 10
allowed_ports      = [22, 80]
count_number       = 1
 tags = {
    Name           = "Stage-Instance"
    ManagedBy   = "Terraform"
 }
