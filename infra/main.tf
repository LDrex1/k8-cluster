terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  region = "af-south-1"
  alias  = "aws-africa"
}

module "vpc" {
  source = "./modules/network/vpc"

}
module "ec2" {
  source = "./modules/compute/ec2"

  k8_subnet_id      = module.vpc.k8_subnet_id
  bastion_subnet_id = module.vpc.bastion_subnet_id
}

