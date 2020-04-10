terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

provider "random" {
  version = "~> 2.0"
}

resource "random_string" "cloudwatch_loggroup_rstring" {
  length  = 8
  special = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "Test1VPC"
}

######################
# Use Client VPN     #
######################

data "aws_acm_certificate" "cert" {
  domain      = var.fqdn
  most_recent = true
  statuses    = ["ISSUED"]
}

module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/client/?ref=v0.12.0"

  client_vpn_cidr_block      = "192.168.8.0/22"
  name                       = random_string.cloudwatch_loggroup_rstring.result
  private_subnet_count       = 2
  private_subnets            = module.vpc.private_subnets
  root_certificate_chain_arn = data.aws_acm_certificate.cert.arn
  server_certificate_arn     = data.aws_acm_certificate.cert.arn
  vpc_id                     = module.vpc.vpc_id
}

