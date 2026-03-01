⚠️ Important Notes
📁 File Structure

terraform.tf, providers.tf, and backend configuration do NOT need to be in separate files.
You can keep everything inside main.tf if desired.
Terraform automatically reads all .tf files in the directory.

📥 How to Check Required Variables

To understand which input variables are required:
Clone the source repository and review the module files.
Open the variables.tf file to see:
Required variables
Variable types
Default values (if provided)
You may also review the root main.tf file to see example values being passed.

📘 Documentation Guidance

In official Terraform modules, required inputs are clearly documented.
For custom modules, the variables.tf and main.tf files serve as the module documentation.
✔ Once you provide all required variable values when calling the module, it is ready to use.

-----------------------------------------------------------------------------------------------------------------------------------------

🚀 Terraform AWS Infrastructure Module
📌 Overview

This Terraform module is used to provision the following AWS resources:

🖥️ EC2 Instances
🗂️ S3 Bucket (for remote state)
🔒 DynamoDB Table (for state locking)

It supports dynamic EC2 creation with proper state management and tagging standards.

⚠️ Important Setup Instructions
1️⃣ Create S3 & DynamoDB First (Recommended)

Before using this module with remote state:
Create the S3 bucket
Create the DynamoDB table
These are required for Terraform remote state storage and state locking.

If they are not created yet:

👉 Temporarily comment out the backend block inside:
terraform.tf

After the S3 bucket and DynamoDB table are created:
Uncomment the backend section

Run:
``` terraform init```

This will configure remote state properly.

🔐 Remote State & Locking Behavior

S3 stores the Terraform state file (.tfstate)
DynamoDB provides state locking
Prevents multiple users from modifying infrastructure at the same time
Ensures safe concurrent operations
After backend is configured, users can create:

Multiple EC2 instances
Safely, with proper locking enabled

⚙️ Backend Configuration Requirement
⚠️ Make sure the following values match exactly:

bucket name in backend "s3" block
dynamodb_table name in backend "s3" block
These names must be the same as the S3 bucket and DynamoDB table you created.

🏷️ Tagging Strategy

This module follows a structured tagging approach:
✅ Default tags are defined inside the module
✅ Users can provide custom tags
✅ If user does not provide tags, default tags will be applied
✅ EC2 instances are uniquely named using an index when multiple instances are created

If skipped, default tags will be used automatically.

📦 Features

Dynamic EC2 creation using count
Secure remote state with S3
State locking with DynamoDB
Versioning-enabled state bucket
Flexible and safe tagging system
Modular and reusable design

🧠 Best Practice Workflow

Create S3 + DynamoDB
Configure backend

```Run terraform init```

```Run terraform plan```

```Run terraform apply```
