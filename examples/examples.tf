provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "Test1VPC"
}

module "vpc2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "Test2VPC"
}

module "vpc3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "Test3VPC"
}

module "sns" {
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.0.2"
  topic_name = "rackspace-managed-test"
}

######################
# Use Static Routing #
######################

module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.2"

  name = "StaticRoutingVPN"

  ##############################
  # Configure Gateway settings #
  ##############################

  vpc_id      = "${module.vpc.vpc_id}"
  customer_ip = "1.2.3.4"

  ###############################
  # Configure Route Propagation #
  ###############################

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3

  ###########################
  # Configure Static Routes #
  ###########################

  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2

  ############################
  # Configure Alarm settings #
  ############################

  alarm_evaluations  = 3
  alarm_period       = 300
  notification_topic = "${module.sns.topic_arn}"

  ###############################
  # Miscellaneous Configuration #
  ###############################

  environment = "Production"
  spoke_vpc   = true
  tags = {
    Tag1 = "Value 1"
  }
}

###############################
# Use an existing VPN gateway #
###############################

module "vpn2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.2"

  name = "StaticRoutingExistingVGW"

  vpc_id               = "${module.vpc.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn1.vpn_gateway}"

  customer_ip = "5.6.7.8"

  route_tables       = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.2.0/23", "192.168.6.0/23"]
  static_routes_count = 2
}

####################################
# Use an existing Customer gateway #
####################################

module "vpn3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.2"

  name = "StaticRoutingExistingCGW"

  vpc_id = "${module.vpc2.vpc_id}"

  create_customer_gateway   = false
  existing_customer_gateway = "${module.vpn1.customer_gateway}"

  route_tables       = "${concat(module.vpc2.public_route_tables, module.vpc2.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2
}

############################################
# Use an existing VPN and Customer gateway #
############################################

module "vpn4" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.2"

  name = "StaticRoutingExistingCGWandVGW"

  vpc_id               = "${module.vpc2.vpc_id}"
  create_vpn_gateway   = false
  existing_vpn_gateway = "${module.vpn3.vpn_gateway}"

  create_customer_gateway   = false
  existing_customer_gateway = "${module.vpn2.customer_gateway}"

  route_tables       = "${concat(module.vpc2.public_route_tables, module.vpc2.private_route_tables)}"
  route_tables_count = 3

  static_routes       = ["192.168.2.0/23", "192.168.6.0/23"]
  static_routes_count = 2
}

#######################
# Use Dynamic Routing #
#######################

module "vpn5" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.2"

  name = "DynamicRoutingVPN"

  vpc_id = "${module.vpc3.vpc_id}"

  customer_ip = "9.10.11.12"

  disable_bgp = false
  bgp_asn     = 65000

  route_tables       = "${concat(module.vpc3.public_route_tables, module.vpc3.private_route_tables)}"
  route_tables_count = 3
}
