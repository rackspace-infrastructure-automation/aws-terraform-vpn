variable "alarm_evaluations" {
  description = "The number of periods over which data is evaluated to monitor VPN connection status."
  type        = number
  default     = 10
}

variable "alarm_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = number
  default     = 60
}

variable "client_vpn_cidr_block" {
  description = "Add the IPv4 address range, in CIDR notation, from which to assign client IP Address must be either /16 or /22 address space"
  type        = string
}

variable "environment" {
  description = "The name of the environment, e.g. Production, Development, etc."
  type        = string
  default     = "development"
}

variable "name" {
  description = "The name prefix for the VPN client resources"
  type        = string
  default     = "vpn-client"
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL)"
  type        = list(string)
  default     = []
}

variable "private_subnet_count" {
  description = "Number of private subnets in the VPC"
  type        = number
  default     = 2
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnet_count" {
  description = "Number of public subnets in the VPC"
  type        = number
  default     = 0
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []
}

variable "root_certificate_chain_arn" {
  description = "The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM)."
  type        = string
}

variable "server_certificate_arn" {
  description = "The server certificate ARN."
  type        = string
}

variable "split_tunnel" {
  description = "Enables/disables split tunnel on the Client VPN."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
