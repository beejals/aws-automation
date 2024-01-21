# Using Python to Automate AWS Services | Lambda and EC2 #
# NOTE: This is still WIP and not complete #
This repo contains Terraform code to create:
1. AWS CloudTrail trail to capture AWS events
2. AWS EventBridge rule to trigger a Lambda function
3. Lambda function written in Pyton

I have taken the example from [Travis Media](https://youtu.be/3DRiruDUhiA?si=t5dbA_T1QpvVZo5f) and created Terraform code to automate the deployment of all the required resource from there.
## Install and config ##
1. Install Terraform - https://developer.hashicorp.com/terraform/install
    * Make sure to add Terraform home directory to your PATH environment variable
2. Create access key for terraform to use to connect to aws.  Update the credentials file on your machine with the key information.  See: https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-csv.titlecli-authentication-user-configure-file
3. Initialize you working directory
```bash
terraform init
```
4. Run terraform plan
```bash
terraform plan
```
5. Run terraform apply
```bash
terraform apply
```
6. Run terraform destroy to terminate your instance
```bash
terraform destroy
```
