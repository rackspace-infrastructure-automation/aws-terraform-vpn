terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "oregon"
  region  = "us-west-2"
  version = "~> 2.7"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "Test1VPC"
}

module "vpc2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "Test2VPC"
}

module "vpc3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "Test3VPC"
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.0"

  name = "rackspace-managed-test"
}

######################
# Use Static Routing #
######################

module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  alarm_evaluations   = 3
  alarm_period        = 300
  customer_ip         = "1.2.3.4"
  environment         = "Production"
  name                = "StaticRoutingVPN"
  notification_topic  = module.sns.topic_arn
  route_tables_count  = 3
  spoke_vpc           = true
  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2
  vpc_id              = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )

  tags = {
    Tag1 = "Value 1"
  }
}

###############################
# Use an existing VPN gateway #
###############################

module "vpn2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  create_vpn_gateway   = false
  customer_ip          = "5.6.7.8"
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "StaticRoutingExistingVGW"
  route_tables_count   = 3
  static_routes        = ["192.168.2.0/23", "192.168.6.0/23"]
  static_routes_count  = 2
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

####################################
# Use an existing Customer gateway #
####################################

module "vpn3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  create_customer_gateway   = false
  existing_customer_gateway = module.vpn1.customer_gateway
  name                      = "StaticRoutingExistingCGW"
  route_tables_count        = 3
  static_routes             = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count       = 2
  vpc_id                    = module.vpc2.vpc_id

  route_tables = concat(
    module.vpc2.public_route_tables,
    module.vpc2.private_route_tables,
  )
}

############################################
# Use an existing VPN and Customer gateway #
############################################

module "vpn4" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  create_customer_gateway   = false
  create_vpn_gateway        = false
  existing_customer_gateway = module.vpn2.customer_gateway
  existing_vpn_gateway      = module.vpn3.vpn_gateway
  name                      = "StaticRoutingExistingCGWandVGW"
  route_tables_count        = 3
  static_routes             = ["192.168.2.0/23", "192.168.6.0/23"]
  static_routes_count       = 2
  vpc_id                    = module.vpc2.vpc_id

  route_tables = concat(
    module.vpc2.public_route_tables,
    module.vpc2.private_route_tables,
  )
}

#######################
# Use Dynamic Routing #
#######################

module "vpn5" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  bgp_asn            = 65000
  customer_ip        = "9.10.11.12"
  disable_bgp        = false
  name               = "DynamicRoutingVPN"
  route_tables_count = 3
  vpc_id             = module.vpc3.vpc_id

  route_tables = concat(
    module.vpc3.public_route_tables,
    module.vpc3.private_route_tables,
  )
}

