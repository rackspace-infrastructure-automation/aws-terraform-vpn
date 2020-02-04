/**
 * # aws-terraform-vpn/modules/client
 * AWS Client VPN is a managed client-based VPN service that enables you to securely access your AWS resources and resources in your on-premises network.
 * With Client VPN, you can access your resources from any location using an OpenVPN-based VPN client.
 *
 * ## Basic Usage
 * 
 * ### Client VPN
 * ```HCL
 * module "vpn1" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/client/?ref=v0.0.4"
 * 
 *   client_vpn_cidr_block      = "192.168.10.0/24"
 *   private_subnet_count       = 2
 *   private_subnets            = [subnet_1, subnet_2]
 *   root_certificate_chain_arn = "arn:aws:acm:REGION:AWS_ACCOUNT:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 *   server_certificate_arn     = "arn:aws:acm:REGION:AWS_ACCOUNT:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 *   vpc_id                     = "vpc_id"
 * 
 * }
 * ```
 *
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.1.0"
  }
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

resource "aws_cloudwatch_log_group" "client_vpn" {
  name = "${var.name}-Client-VPN-lg"
  tags = merge(
    {
      "Name" = "${var.name}-ClientVpnConnection"
    },
    var.tags,
    local.tags,
  )
}

resource "aws_cloudwatch_log_stream" "client_vpn" {
  name           = "${var.name}-Client-VPN-ls"
  log_group_name = aws_cloudwatch_log_group.client_vpn.name
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "Client Vpn CIDR block must not overlap users network"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_vpn_cidr_block

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_chain_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client_vpn.name
  }
}

module "client_vpn_status" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_description        = "${var.name}-VPN Connection State"
  alarm_name               = "${var.name}-VPN-Status"
  comparison_operator      = "LessThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = var.alarm_evaluations
  metric_name              = "TunnelState"
  namespace                = "AWS/VPN"
  notification_topic       = var.notification_topic
  period                   = var.alarm_period
  rackspace_alarms_enabled = false
  statistic                = "Maximum"
  threshold                = "0"

  dimensions = [
    {
      VpnId = aws_ec2_client_vpn_endpoint.client_vpn.id
    },
  ]
}

resource "aws_ec2_client_vpn_network_association" "private" {
  count = var.private_subnet_count

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = element(var.private_subnets, count.index)
}

resource "aws_ec2_client_vpn_network_association" "public" {
  count = var.public_subnet_count

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = element(var.public_subnets, count.index)
}

resource "aws_security_group" "client_vpn_security_group" {
  name_prefix = "${var.name}-ClientVpnSecurityGroup"
  description = "Client VPN Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${var.name}-ClientVpnSecurityGroup"
    },
  )
}

