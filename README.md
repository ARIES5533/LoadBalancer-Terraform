# Introduction

This project utilizes Terraform to deploy an AWS infrastructure for a ARIES application. It involves the creation of a Virtual Private Cloud (VPC), public and private subnets, an Internet Gateway, a Network Address Translation (NAT) Gateway, and an Application Load Balancer (ALB) with associated resources.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://www.terraform.io/downloads.html) installed.
- AWS access key and secret key.
- AWS CLI configured with the required permissions.

## Getting Started

1. **Clone this repository:**

    ```bash
    https://github.com/ARIES5533/LoadBalancer-Terraform.git
    ```

2. **Update the provider "aws" block in `main.tf` with your AWS credentials.**

3. **Initialize your Terraform working directory and run Terraform plan after:**

    ```bash
    terraform init
    ```

4. **Review and customize the configuration in `main.tf` as needed.**

5. **Apply the Terraform configuration:**

    ```bash
    terraform apply
    ```

    Confirm with `yes` when prompted.





# Configuration Details

## VPC
- **CIDR Block:** 10.0.0.0/16
- **DNS Support:** Enabled
- **DNS Hostnames:** Enabled

## Public Subnet
- **CIDR Block:** 10.0.3.0/24
- **Availability Zone:** us-east-1a

## Private Subnet
- **CIDR Block:** 10.0.2.0/24
- **Availability Zone:** us-east-1b

## Security Group
- **Name:** ARIES-Security-Group
- **Ingress Rules:**
  - Allow incoming traffic on port 80, 443, and 22
- **Egress Rules:**
  - Allow all outgoing traffic

## ALB and Target Group
- **ALB Name:** ARIES-alb
- **Listener Configuration:**
  - Port 80: Redirect traffic to port 443
  - Port 443: Forward traffic to the target group
- **Target Group Configuration:**
  - Name: ARIES-tg
  - Target Type: instance
  - Health Check Path: /index.html
  - Port: 443
  - Protocol: HTTPS

## Terraform Commands
- `terraform init`: Initialize the Terraform working directory.
- `terraform apply`: Apply the configuration and create resources.
- `terraform destroy`: Destroy the infrastructure.

For SSL termination, provide the ACM certificate ARN in the `certificate_arn` field.
