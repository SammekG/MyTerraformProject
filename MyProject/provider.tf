terraform {
  required_version = "~> 1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
  backend "s3" {
    bucket = "my-state-file-bk"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}