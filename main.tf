terraform {

  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "mapfre-tfenabled"
    key    = "ce/aws-vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      owner      = "Aloysio Coutinho"
      managed-by = "terraform"
      projeto    = "Cloud Enablement"
    }
  }
}