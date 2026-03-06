# Terraform AMI Lookup – DevOps Quick Reference

This guide explains the **best practice for selecting AMIs dynamically** in Terraform instead of hard-coding AMI IDs.

Hardcoding AMI (not recommended):

```hcl
ami = "ami-123456"
```

AMIs change frequently, so Terraform provides **data sources** to fetch them dynamically.

---

# 1. Basic AMI Lookup Pattern

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

### How Terraform Reads This

```
data.aws_ami.ubuntu.id
│    │     │      └── attribute returned
│    │     └── user defined name
│    └── resource type
└── terraform data source
```

---

# 2. Common AMI Filters Used in DevOps

## Filter by Name (OS Version)

```hcl
filter {
  name   = "name"
  values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}
```

Purpose:

Select a specific OS version.

Example matches:

```
ubuntu-jammy-22.04-server-20240101
ubuntu-jammy-22.04-server-20240215
```

`most_recent = true` ensures Terraform picks the **latest build**.

---

## Filter by Virtualization Type

```hcl
filter {
  name   = "virtualization-type"
  values = ["hvm"]
}
```

Most modern EC2 instances use **HVM virtualization**.

---

## Filter by Architecture

```hcl
filter {
  name   = "architecture"
  values = ["x86_64"]
}
```

Common architectures:

```
x86_64 → Intel / AMD CPUs
arm64  → AWS Graviton CPUs
```

Example:

```
t3.micro  → x86_64
t4g.micro → arm64
```

---

## Filter by Root Device Type

```hcl
filter {
  name   = "root-device-type"
  values = ["ebs"]
}
```

Why?

```
EBS → persistent storage
instance-store → temporary storage
```

---

# 3. Production Example (Real DevOps Terraform)

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

---

# 4. DevOps Memory Shortcut

Most engineers remember this syntax pattern:

```
data.<provider>_<resource>.<name>.<attribute>
```

Example:

```
data.aws_ami.ubuntu.id
```

Meaning:

```
provider  → aws
resource  → ami
name      → ubuntu
attribute → id
```

---

# 5. Best Practice

❌ Avoid

```hcl
ami = "ami-123456"
```

✅ Use dynamic lookup

```hcl
ami = data.aws_ami.ubuntu.id
```

This ensures your infrastructure always uses the **latest patched AMI** while keeping the OS version consistent.
