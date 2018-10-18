# aws-terraform-vpn

This module deploys the required infrastructure for a VPN to a customer's on premesis network.


## Basic Usage

### Static Routing
```
module "vpn1" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.1"

 name                = "StaticRoutingVPN"
 customer_ip         = "1.2.3.4"
 route_tables        = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
 route_tables_count  = 3
 static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
 static_routes_count = 2
 vpc_id              = "${module.vpc.vpc_id}"
 # preshared_keys   = ["WeeshaiYoo2phooC", "WeeshaiYoo2phooC"]
 # bgp_inside_cidrs = ["169.254.18.0/30", "169.254.17.0/30"]
}
```

### Dynamic Routing
```
module "vpn1" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//?ref=v0.0.1"

 name                = "DynamicRoutingVPN"
 bgp_asn             = 65000
 customer_ip         = "1.2.3.4"
 disable_bgp         = false
 route_tables        = "${concat(module.vpc.public_route_tables, module.vpc.private_route_tables)}"
 route_tables_count  = 3
 vpc_id              = "${module.vpc.vpc_id}"
 # preshared_keys   = ["WeeshaiYoo2phooC", "WeeshaiYoo2phooC"]
 # bgp_inside_cidrs = ["169.254.18.0/30", "169.254.17.0/30"]
}
```



Full working references are available at [examples](examples)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_evaluations | The number of periods over which data is evaluated to monitor VPN connection status. | string | `10` | no |
| alarm_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | string | `60` | no |
| bgp_asn | An existing ASN assigned to the remote network, or one of the private ASNs in the 64512 - 65534 range.  Exceptions: 7224 cannot be used in the us-east-1 region and 9059 cannot be used in eu-west-1 region. | string | `65000` | no |
| create_customer_gateway | Boolean value to determine if a customer gateway resource will be created. | string | `true` | no |
| create_vpn_gateway | Boolean value to determine if a VPN gateway resource will be created. | string | `true` | no |
| customer_ip | The IP address of the Customer Endpoint.  Ignored if not creating a customer gateway. | string | `` | no |
| disable_bgp | Boolean value to determine if BGP routing protocol should be disabled for the VPN connection.  If static routes are required for this VPN this value should be set to true. | string | `true` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | string | `Development` | no |
| existing_customer_gateway | The id of an existing customer gateway to use for the VPN.  Must be provided if not creating a customer gateway. | string | `` | no |
| existing_vpn_gateway | The id of an existing VPN gateway to use for the VPN.  Must be provided if not creating a VPN gateway. | string | `` | no |
| name | The name prefix for these IAM resources | string | - | yes |
| notification_topic | SNS Topic ARN to use for customer notifications from CloudWatch alarms. (OPTIONAL) | string | `` | no |
| route_tables | A list of route tables to configure for route propagation. | list | `<list>` | no |
| route_tables_count | The number of route tables to configure for route propagation. | string | `0` | no |
| spoke_vpc | Boolean value to determine if VPC is a spoke in a VPN Hub. | string | `false` | no |
| static_routes | A list of internal subnets on the customer side. The subnets must be in valid CIDR notation(x.x.x.x/x). | list | `<list>` | no |
| static_routes_count | The number of internal subnets on the customer side. | string | `0` | no |
| tags | Custom tags to apply to all resources. | map | `<map>` | no |
| vpc_id | Provide Virtual Private Cloud ID in which the VPN resources will be deployed | string | - | yes |
| preshared_keys | Pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. Allowed characters are alphanumeric characters and ._. Must be between 8 and 64 characters in length and cannot start with zero (0). | list | [] | no
| bgp_inside_cidrs | Range of inside IP addresses for the tunnel. Any specified CIDR blocks must be unique across all VPN connections that use the same virtual private gateway. A size /30 CIDR block from the 169.254.0.0/16 range. The following CIDR blocks are reserved and cannot be used: 169.254.0.0/30, 169.254.1.0/30, 169.254.2.0/30, 169.254.3.0/30, 169.254.4.0/30, 169.254.5.0/30, 169.254.169.252/30 | list | [] | no

## Outputs

| Name | Description |
|------|-------------|
| customer_gateway | Customer Gateway ID |
| vpn_gateway | VPN Gateway ID |

