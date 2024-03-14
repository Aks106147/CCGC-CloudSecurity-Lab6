# CCGC-CloudSecurity-Lab6 

## Overview:
This lab serves as a demonstration of setting up a basic AWS infrastructure using Terraform while adhering to security best practices. The infrastructure will include a VPC, a subnet, an EC2 instance, and an S3 bucket along with other supporting resources. The EC2 instance will be assigned a role granting it access to a specific S3 bucket. This guide provides step-by-step instructions to deploy and clean up the infrastructure.

## Prerequisites:
An AWS account with necessary permissions to create resources.
AWS CLI configured with appropriate credentials.
Terraform installed on your local machine.

## Setup Instructions:

### Basic AWS Account Setup:
Create a new user account with programmatic access.
Attach the AdministratorAccess policy to the user.
Configure AWS CLI with the access key and secret key of the newly created user.

### Terraform Setup:
Ensure Terraform is installed by running the following code:
```bash
terraform --version
```
Clone this repository and navigate to the project directory.

Initialize the project and install necessary plugins with the following code:
```bash
terraform init
```

## Deployment:
Once prerequisites are met and the project is initialized, execute the following command to deploy the infrastructure:
```bash
terraform apply
```

## Cleanup:
To remove the EC2 policy and role created in the lab, execute the following commands:

```bash
# Get the policy ARN from Terraform output
policy_arn=$(terraform output -raw policy_arn)

# Get the IAM role name from Terraform output
role_name=$(terraform output -raw ec2_role_name)

# Get the IAM instance profile name from Terraform output
instance_profile_name=$(terraform output -raw ec2_instance_profile_name)

# Detach the IAM policy from the IAM role using AWS CLI
aws iam detach-role-policy --policy-arn $policy_arn --role-name $role_name

# Remove the role from instance profile
aws iam remove-role-from-instance-profile --role-name $role_name --instance-profile-name $instance_profile_name

# Delete the instance profile from AWS
aws iam delete-instance-profile --instance-profile-name $instance_profile_name

# Delete the IAM role from AWS
aws iam delete-role --role-name $role_name
```

## Infrastructure Destruction:
To destroy the infrastructure created by Terraform, execute the following command:

```bash
terraform destroy
```







