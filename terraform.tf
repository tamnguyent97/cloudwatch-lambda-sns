terraform {
  required_providers {
    aws = {
      version = ">= 5.0.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region

  profile = var.profile
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}