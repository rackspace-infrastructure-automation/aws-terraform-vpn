provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//"

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

  customer_ip = "9.10.11.12"

  disable_bgp = false
  bgp_asn     = 65000

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3
}
