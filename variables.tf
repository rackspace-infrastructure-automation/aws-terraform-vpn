variable "name" {
  description = "The name prefix for these IAM resources"
  type        = "string"
}

variable "alarm_evaluations" {
  description = "The number of periods over which data is evaluated to monitor VPN connection status."
  type        = "string"
  default     = 10
}

variable "alarm_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = "string"
  default     = 60
}

variable "bgp_asn" {
  description = "An existing ASN assigned to the remote network, or one of the private ASNs in the 64512 - 65534 range.  Exceptions: 7224 cannot be used in the us-east-1 region and 9059 cannot be used in eu-west-1 region."
  type        = "string"
  default     = 65000
}

variable "create_customer_gateway" {
  description = "Boolean value to determine if a customer gateway resource will be created."
  type        = "string"
  default     = true
}

variable "create_vpn_gateway" {
  description = "Boolean value to determine if a VPN gateway resource will be created."
  type        = "string"
  default     = true
}

variable "customer_ip" {
  description = "The IP address of the Customer Endpoint.  Ignored if not creating a customer gateway."
  type        = "string"
  default     = ""
}

variable "disable_bgp" {
  description = "Boolean value to determine if BGP routing protocol should be disabled for the VPN connection.  If static routes are required for this VPN this value should be set to true."
  type        = "string"
  default     = true
}

variable "environment" {
  description = "Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test')"
  type        = "string"
  default     = "Development"
}

variable "existing_customer_gateway" {
  description = "The id of an existing customer gateway to use for the VPN.  Must be provided if not creating a customer gateway."
  type        = "string"
  default     = ""
}

variable "existing_vpn_gateway" {
  description = "The id of an existing VPN gateway to use for the VPN.  Must be provided if not creating a VPN gateway."
  type        = "string"
  default     = ""
}

variable "notification_topic" {
  description = "SNS Topic ARN to use for customer notifications from CloudWatch alarms. (OPTIONAL)"
  type        = "string"
  default     = ""
}

variable "route_tables" {
  description = "A list of route tables to configure for route propagation."
  type        = "list"
  default     = []
}

variable "route_tables_count" {
  description = "The number of route tables to configure for route propagation."
  type        = "string"
  default     = 0
}

variable "spoke_vpc" {
  description = "Boolean value to determine if VPC is a spoke in a VPN Hub."
  type        = "string"
  default     = false
}

variable "static_routes" {
  description = "A list of internal subnets on the customer side. The subnets must be in valid CIDR notation(x.x.x.x/x)."
  type        = "list"
  default     = []
}

variable "static_routes_count" {
  description = "The number of internal subnets on the customer side."
  type        = "string"
  default     = 0
}

variable "tags" {
  description = "Custom tags to apply to all resources."
  type        = "map"
  default     = {}
}

variable "vpc_id" {
  description = "Provide Virtual Private Cloud ID in which the VPN resources will be deployed"
  type        = "string"
}
