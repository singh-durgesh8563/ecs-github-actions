terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1" # Mumbai
}

provider "aws" {
  region = var.aws_region
}
