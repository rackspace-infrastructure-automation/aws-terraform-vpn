/**
 * # aws-terraform-vpn
 *
 * This module deploys the required infrastructure for a VPN to a customer's on premesis network.
 *
 *
 *## Basic Usage
 *
 *### Static Routing
 *```
 *module "vpn1" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.1"
 *
 *  name                = "StaticRoutingVPN"
 *  customer_ip         = "1.2.3.4"
 *  route_tables        = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
 *  route_tables_count  = 3
 *  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
 *  static_routes_count = 2
 *  vpc_id              = "${module.vpc.vpc_id}"
 *}
 *```
 *
 *### Dynamic Routing
 *```
 *module "vpn1" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.1"
 *
 *  name                = "DynamicRoutingVPN"
 *  bgp_asn             = 65000
 *  customer_ip         = "1.2.3.4"
 *  disable_bgp         = false
 *  route_tables        = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
 *  route_tables_count  = 3
 *  vpc_id              = "${module.vpc.vpc_id}"
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 */

locals {
  tags {
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }

  customer_gateway = "${element(
    compact(concat(
      list(var.existing_customer_gateway),
      aws_customer_gateway.customer_gateway.*.id
    )),
    0
  )}"

  vpn_gateway = "${element(
    compact(concat(
      list(var.existing_vpn_gateway),
      aws_vpn_gateway.vpn_gateway.*.id
    )),
    0
  )}"
}

resource "aws_customer_gateway" "customer_gateway" {
  count = "${var.create_customer_gateway ? 1 : 0}"

  bgp_asn    = "${var.bgp_asn}"
  ip_address = "${var.customer_ip}"
  type       = "ipsec.1"
  tags       = "${merge(map("Name", "${var.name}-CustomerGateway"), var.tags, local.tags)}"
}

resource "aws_vpn_gateway" "vpn_gateway" {
  count = "${var.create_vpn_gateway  ? 1 : 0}"

  tags = "${merge(
    map("Name", "${var.name}-VPNGateway"),
    map("transitvpc:spoke", "${var.spoke_vpc ? "True" : "False"}"),
    var.tags,
    local.tags
  )}"

  vpc_id = "${var.vpc_id}"
}

resource "aws_vpn_connection" "vpn_connection" {
  count               = "${length(var.preshared_keys) == 0 && length(var.bgp_inside_cidrs) == 0 ? 1 : 0}"
  customer_gateway_id = "${local.customer_gateway}"
  static_routes_only  = "${var.disable_bgp}"
  tags                = "${merge(map("Name", "${var.name}-VpnConnection"), var.tags, local.tags)}"
  type                = "ipsec.1"
  vpn_gateway_id      = "${local.vpn_gateway}"
}

resource "aws_vpn_connection" "vpn_connection_custom_presharedkey" {
  count                 = "${length(var.preshared_keys) > 0 && length(var.bgp_inside_cidrs) == 0  ? 1 : 0}"
  customer_gateway_id   = "${local.customer_gateway}"
  static_routes_only    = "${var.disable_bgp}"
  tags                  = "${merge(map("Name", "${var.name}-VpnConnection"), var.tags, local.tags)}"
  type                  = "ipsec.1"
  vpn_gateway_id        = "${local.vpn_gateway}"
  tunnel1_preshared_key = "${element(var.preshared_keys,0)}"
  tunnel2_preshared_key = "${element(var.preshared_keys,1)}"
}

resource "aws_vpn_connection" "vpn_connection_custom_inside_cidr" {
  count               = "${length(var.preshared_keys) == 0 && length(var.bgp_inside_cidrs) > 0 ? 1 : 0}"
  customer_gateway_id = "${local.customer_gateway}"
  static_routes_only  = "${var.disable_bgp}"
  tags                = "${merge(map("Name", "${var.name}-VpnConnection"), var.tags, local.tags)}"
  type                = "ipsec.1"
  vpn_gateway_id      = "${local.vpn_gateway}"
  tunnel1_inside_cidr = "${element(var.bgp_inside_cidrs,0)}"
  tunnel2_inside_cidr = "${element(var.bgp_inside_cidrs,1)}"
}

resource "aws_vpn_connection" "vpn_connection_custom_attributes" {
  count                 = "${length(var.preshared_keys) > 0 && length(var.bgp_inside_cidrs) > 0 ? 1 : 0}"
  customer_gateway_id   = "${local.customer_gateway}"
  static_routes_only    = "${var.disable_bgp}"
  tags                  = "${merge(map("Name", "${var.name}-VpnConnection"), var.tags, local.tags)}"
  type                  = "ipsec.1"
  vpn_gateway_id        = "${local.vpn_gateway}"
  tunnel1_preshared_key = "${element(var.preshared_keys,0)}"
  tunnel2_preshared_key = "${element(var.preshared_keys,1)}"
  tunnel1_inside_cidr   = "${element(var.bgp_inside_cidrs,0)}"
  tunnel2_inside_cidr   = "${element(var.bgp_inside_cidrs,1)}"
}

resource "aws_vpn_connection_route" "static_routes" {
  count = "${var.disable_bgp ? var.static_routes_count : 0}"

  destination_cidr_block = "${element(var.static_routes, count.index)}"
  vpn_connection_id      = "${element(concat(aws_vpn_connection.vpn_connection.*.id,aws_vpn_connection.vpn_connection_custom_presharedkey.*.id,aws_vpn_connection.vpn_connection_custom_inside_cidr.*.id,aws_vpn_connection.vpn_connection_custom_attributes.*.id, list("")), 0)}"
}

resource "aws_vpn_gateway_route_propagation" "route_propagation" {
  count = "${var.route_tables_count}"

  route_table_id = "${element(var.route_tables, count.index)}"
  vpn_gateway_id = "${local.vpn_gateway}"
}

resource "aws_cloudwatch_metric_alarm" "vpn_status" {
  alarm_actions       = ["${compact(list(var.notification_topic))}"]
  alarm_description   = "${var.name}-VPN Connection State"
  alarm_name          = "${var.name}-VPN-Status"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.alarm_evaluations}"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "${var.alarm_period}"
  statistic           = "Maximum"
  threshold           = "0"

  dimensions {
    VpnId = "${element(concat(aws_vpn_connection.vpn_connection.*.id,aws_vpn_connection.vpn_connection_custom_presharedkey.*.id,aws_vpn_connection.vpn_connection_custom_inside_cidr.*.id,aws_vpn_connection.vpn_connection_custom_attributes.*.id, list("")), 0)}"
  }
}
