
terraform {
  backend "s3" {
    bucket = "beejals-terraform-backend"
    key    = "aws-automation/terraform.tfstate"
    region = "ca-central-1"
  }
}
