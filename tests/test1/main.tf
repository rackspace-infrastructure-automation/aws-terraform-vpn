terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.2"
  region  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  name = "Test1VPC"
}

######################
# Use Static Routing #
######################

module "vpn1" {
  source = "../../module/modules/site"

  customer_ip         = "1.2.3.4"
  name                = "StaticRoutingVPN"
  route_tables_count  = 3
  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2
  vpc_id              = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

#######################
# Use Dynamic Routing #
#######################

module "vpn2" {
  source = "../../module/modules/site"

  bgp_asn              = 65000
  create_vpn_gateway   = false
  customer_ip          = "1.2.3.5"
  disable_bgp          = false
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "DynamicRoutingVPN"
  route_tables_count   = 3
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

##########################
# PresharedKey values    #
##########################

resource "random_string" "presharedkey1" {
  length  = 16
  lower   = true
  number  = true
  special = false
  upper   = true
}

############################################
# Use Static Routing With PresharedKey #
############################################

module "vpn3" {
  source = "../../module/modules/site"

  create_vpn_gateway   = false
  customer_ip          = "1.2.3.6"
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "StaticRoutingVPN-PSK"
  preshared_keys       = [random_string.presharedkey1.result]
  route_tables_count   = 3
  static_routes        = ["192.168.12.0/23", "192.168.16.0/23"]
  static_routes_count  = 2
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

##############################################
# Use Dynamic Routing with preshared key#
##############################################

module "vpn4" {
  source = "../../module/modules/site"

  bgp_asn              = 65001
  create_vpn_gateway   = false
  customer_ip          = "1.2.3.7"
  disable_bgp          = false
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "DynamicRoutingVPN-PSK"
  preshared_keys       = [random_string.presharedkey1.result]
  route_tables_count   = 3
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

##############################################
# Use Dynamic Routing with preshared key and inside CIDR#
##############################################

module "vpn5" {
  source = "../../module/modules/site"

  bgp_asn              = 65002
  bgp_inside_cidrs     = ["169.254.16.0/30", "169.254.15.0/30"]
  create_vpn_gateway   = false
  customer_ip          = "1.2.3.8"
  disable_bgp          = false
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "DynamicRoutingVPN-PSK-ICIDR"
  preshared_keys       = [random_string.presharedkey1.result]
  route_tables_count   = 3
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

##############################################
# Use Dynamic Routing with inside CIDR#
##############################################

module "vpn6" {
  source = "../../module/modules/site"

  bgp_asn              = 65003
  bgp_inside_cidrs     = ["169.254.12.0/30", "169.254.13.0/30"]
  create_vpn_gateway   = false
  customer_ip          = "1.2.3.9"
  disable_bgp          = false
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "DynamicRoutingVPN-ICIDR"
  route_tables_count   = 3
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

############################################
# Use Static Routing With PresharedKey and IncideCidr #
############################################

module "vpn7" {
  source = "../../module/modules/site"

  bgp_inside_cidrs     = ["169.254.18.0/30", "169.254.17.0/30"]
  create_vpn_gateway   = false
  customer_ip          = "1.2.3.10"
  existing_vpn_gateway = module.vpn1.vpn_gateway
  name                 = "StaticRoutingVPN-PSK-ICIDR"
  preshared_keys       = [random_string.presharedkey1.result]
  route_tables_count   = 3
  static_routes        = ["192.168.18.0/23", "192.168.20.0/23"]
  static_routes_count  = 2
  vpc_id               = module.vpc.vpc_id

  route_tables = concat(
    module.vpc.public_route_tables,
    module.vpc.private_route_tables,
  )
}

