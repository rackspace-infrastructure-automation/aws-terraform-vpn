variable "alarm_evaluations" {
  default     = 10
  description = "The number of periods over which data is evaluated to monitor VPN connection status."
  type        = "string"
}

variable "alarm_period" {
  default     = 60
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = "string"
}

variable "client_vpn_cidr_block" {
  description = "Add the IPv4 address range, in CIDR notation, from which to assign client IP Address must be either /16 or /22 address space"
  type        = "string"
}

variable "environment" {
  default     = "development"
  description = "The name of the environment, e.g. Production, Development, etc."
  type        = "string"
}

variable "name" {
  default     = "vpn-client"
  description = "The name prefix for the VPN client resources"
  type        = "string"
}

variable "notification_topic" {
  default     = []
  description = "List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL)"
  type        = "list"
}

variable "private_subnet_count" {
  default     = "2"
  description = "Number of private subnets in the VPC"
  type        = "string"
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = "list"
}

variable "public_subnet_count" {
  default     = "0"
  description = "Number of public subnets in the VPC"
  type        = "string"
}

variable "public_subnets" {
  default     = []
  description = "List of public subnets"
  type        = "list"
}

variable "root_certificate_chain_arn" {
  description = "The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM)."
  type        = "string"
}

variable "server_certificate_arn" {
  description = "The server certificate ARN."
  type        = "string"
}

variable "tags" {
  default     = {}
  description = "Custom tags to apply to all resources."
  type        = "map"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}
