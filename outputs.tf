output "vpn_gateway" {
  description = "VPN Gateway ID"
  value       = "${local.vpn_gateway}"
}

output "customer_gateway" {
  description = "Customer Gateway ID"
  value       = "${local.customer_gateway}"
}
