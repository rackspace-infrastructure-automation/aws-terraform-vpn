/**
 * # aws-terraform-vpn
 *
 * This module deploys the required infrastructure for a VPN to a customer's on-premise network.
 *
 * ## Basic Usage
 * 
 * ### Static Routing
 * ```
 * module "vpn1" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"
 * 
 *   name                = "StaticRoutingVPN"
 *   customer_ip         = "1.2.3.4"
 *   route_tables        = concat(module.vpc.public_route_tables, module.vpc.private_route_tables)
 *   route_tables_count  = 3
 *   static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
 *   static_routes_count = 2
 *   vpc_id              = module.vpc.vpc_id
 *   # preshared_keys      = ["XXXXXXXXXXXXX1", "XXXXXXXXXXXXX2"] #Always use aws_kms_secrets to manage sensitive information. More info: https://manage.rackspace.com/aws/docs/product-guide/iac_beta/managing-secrets.html
 * }
 * ```
 * 
 * ### Dynamic Routing
 * ```
 * module "vpn1" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"
 * 
 *   name                = "DynamicRoutingVPN"
 *   bgp_asn             = 65000
 *   customer_ip         = "1.2.3.4"
 *   disable_bgp         = false
 *   route_tables        = concat(module.vpc.public_route_tables, module.vpc.private_route_tables)
 *   route_tables_count  = 3
 *   vpc_id              = module.vpc.vpc_id
 *   # preshared_keys      = ["XXXXXXXXXXXXX1", "XXXXXXXXXXXXX2"] #Always use aws_kms_secrets to manage sensitive information: More info: https://manage.rackspace.com/aws/docs/product-guide/iac_beta/managing-secrets.html
 *   # bgp_inside_cidrs    = ["169.254.18.0/30", "169.254.17.0/30"]
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 * ## Limitations
 *
 * - When utilizing multiple keys with the `preshared_keys` variable, terraform may have issues determining which of the VPN tunnels each applies to.  This issue is outlined at https://github.com/terraform-providers/terraform-provider-aws/issues/3359.  If this issue is encountered, it is advised to discontinue use of custom preshared keys, or to only provide a single key which would be used on both tunnels.
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * 	- vpn_status
 *
 * ## Terraform 0.12 upgrade
 *
 * Several resources were consolidated, taking advantage of Terraform v0.12.x features.  The following statements 
 * can be used to update existing resources.  In each command, `<MODULE_NAME>` should be replaced with the logic 
 * name used where the module is referenced.
 *
 * ```
 * terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
 * terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_attributes[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
 * terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_inside_cidr[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
 * terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_presharedkey[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
 * ```
 * ### Module variables
 *
 * The following module variables were removed as they are no longer necessary:
 *
 * - `use_bgp_inside_cidrs`
 * - `use_preshared_keys`
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }

  customer_gateway = element(
    compact(
      concat(
        [var.existing_customer_gateway],
        aws_customer_gateway.customer_gateway.*.id,
      ),
    ),
    0,
  )

  vpn_gateway = element(
    compact(
      concat([var.existing_vpn_gateway], aws_vpn_gateway.vpn_gateway.*.id),
    ),
    0,
  )
}

resource "aws_customer_gateway" "customer_gateway" {
  count = var.create_customer_gateway ? 1 : 0

  bgp_asn    = var.bgp_asn
  ip_address = var.customer_ip
  type       = "ipsec.1"

  tags = merge(
    var.tags,
    local.tags,
    {
      "Name" = "${var.name}-CustomerGateway"
    },
  )
}

resource "aws_vpn_gateway" "vpn_gateway" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    local.tags,
    {
      "Name"             = "${var.name}-VPNGateway"
      "transitvpc:spoke" = var.spoke_vpc ? "True" : "False"
    },
  )
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id   = local.customer_gateway
  static_routes_only    = var.disable_bgp
  tunnel1_inside_cidr   = length(var.bgp_inside_cidrs) >= 2 ? element(var.bgp_inside_cidrs, 0) : null
  tunnel1_preshared_key = length(var.preshared_keys) > 0 ? element(var.preshared_keys, 0) : null
  tunnel2_inside_cidr   = length(var.bgp_inside_cidrs) >= 2 ? element(var.bgp_inside_cidrs, 1) : null
  tunnel2_preshared_key = length(var.preshared_keys) > 0 ? element(var.preshared_keys, 1) : null
  type                  = "ipsec.1"
  vpn_gateway_id        = local.vpn_gateway

  tags = merge(
    var.tags,
    local.tags,
    {
      "Name" = "${var.name}-VpnConnection"
    },
  )
}

resource "aws_vpn_connection_route" "static_routes" {
  count = var.disable_bgp ? var.static_routes_count : 0

  destination_cidr_block = element(var.static_routes, count.index)
  vpn_connection_id      = aws_vpn_connection.vpn.id
}

resource "aws_vpn_gateway_route_propagation" "route_propagation" {
  count = var.route_tables_count

  route_table_id = element(var.route_tables, count.index)
  vpn_gateway_id = local.vpn_gateway
}

module "vpn_status" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_description        = "${var.name}-VPN Connection State"
  alarm_name               = "${var.name}-VPN-Status"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = [{ VpnId = aws_vpn_connection.vpn.id }]
  evaluation_periods       = var.alarm_evaluations
  metric_name              = "TunnelState"
  namespace                = "AWS/VPN"
  notification_topic       = var.notification_topic
  period                   = var.alarm_period
  rackspace_alarms_enabled = false
  statistic                = "Maximum"
  threshold                = 0
}

