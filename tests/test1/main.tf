provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  vpc_name = "Test1VPC"
}

######################
# Use Static Routing #
######################

module "vpn1" {
  source = "../../module"

  name = "StaticRoutingVPN"

  vpc_id      = "${module.vpc.vpc_id}"
  customer_ip = "1.2.3.4"

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2
}

#######################
# Use Dynamic Routing #
#######################

module "vpn2" {
  source = "../../module"

  name = "DynamicRoutingVPN"

  vpc_id               = "${module.vpc.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  customer_ip = "1.2.3.5"

  disable_bgp = false
  bgp_asn     = 65000

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3
}

############################################
# Use Static Routing With PresharedKey #
############################################

module "vpn3" {
  source = "../../module"

  name = "StaticRoutingVPN-PSK"

  vpc_id               = "${module.vpc.vpc_id}"
  customer_ip          = "1.2.3.6"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.12.0/23", "192.168.16.0/23"]
  static_routes_count = 2

  preshared_keys = ["WeeshaiYoo2phooC", "WeeshaiYoo2pho23"]
}

##############################################
# Use Dynamic Routing with preshared key#
##############################################

module "vpn4" {
  source = "../../module"

  name = "DynamicRoutingVPN-PSK"

  vpc_id               = "${module.vpc.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  customer_ip = "1.2.3.7"

  disable_bgp = false
  bgp_asn     = 65001

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3
  preshared_keys     = ["WeeshaiYoo2phooC", "WeeshaiYoo2pho23"]
}

##############################################
# Use Dynamic Routing with preshared key and inside CIDR#
##############################################

module "vpn5" {
  source = "../../module"

  name = "DynamicRoutingVPN-PSK-ICIDR"

  vpc_id               = "${module.vpc.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  customer_ip = "1.2.3.8"

  disable_bgp = false
  bgp_asn     = 65002

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3
  preshared_keys     = ["WeeshaiYoo2phooC", "WeeshaiYoo2pho23"]
  bgp_inside_cidrs   = ["169.254.16.0/30", "169.254.15.0/30"]
}

##############################################
# Use Dynamic Routing with inside CIDR#
##############################################

module "vpn6" {
  source = "../../module"

  name = "DynamicRoutingVPN-ICIDR"

  vpc_id               = "${module.vpc.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  customer_ip = "1.2.3.9"

  disable_bgp = false
  bgp_asn     = 65003

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3
  bgp_inside_cidrs   = ["169.254.12.0/30", "169.254.13.0/30"]
}

############################################
# Use Static Routing With PresharedKey and IncideCidr #
############################################

module "vpn7" {
  source = "../../module"

  name = "StaticRoutingVPN-PSK-ICIDR"

  vpc_id               = "${module.vpc.vpc_id}"
  customer_ip          = "1.2.3.10"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.18.0/23", "192.168.20.0/23"]
  static_routes_count = 2

  preshared_keys   = ["WeeshaiYoo2phooC", "WeeshaiYoo2pho23"]
  bgp_inside_cidrs = ["169.254.18.0/30", "169.254.17.0/30"]
}
