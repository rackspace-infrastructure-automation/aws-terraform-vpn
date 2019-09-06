provider "aws" {
  version = "~> 1.2"
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  vpc_name = "Test1VPC"
}

######################
# Use Client VPN     #
######################

data "aws_acm_certificate" "cert" {
  domain      = "www.mupo181ve1jco37.net"
  statuses    = ["ISSUED"]
  most_recent = true
}

module "vpn1" {
  source = "../../module/modules/client"

  client_vpn_cidr_block      = "192.168.8.0/22"
  private_subnet_count       = 2
  private_subnets            = "${module.vpc.private_subnets}"
  root_certificate_chain_arn = "${data.aws_acm_certificate.cert.arn}"
  server_certificate_arn     = "${data.aws_acm_certificate.cert.arn}"
  vpc_id                     = "${module.vpc.vpc_id}"
  name                       = "${random_string.cloudwatch_loggroup_rstring.result}"
}
