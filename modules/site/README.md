# aws-terraform-vpn

This module deploys the required infrastructure for a VPN to a customer's on-premise network.

## Basic Usage

### Static Routing
```
module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  name                = "StaticRoutingVPN"
  customer_ip         = "1.2.3.4"
  route_tables        = concat(module.vpc.public_route_tables, module.vpc.private_route_tables)
  route_tables_count  = 3
  static_routes       = ["192.168.0.0/23", "192.168.4.0/23"]
  static_routes_count = 2
  vpc_id              = module.vpc.vpc_id
  # preshared_keys      = ["XXXXXXXXXXXXX1", "XXXXXXXXXXXXX2"] #Always use aws_kms_secrets to manage sensitive information. More info: https://manage.rackspace.com/aws/docs/product-guide/iac_beta/managing-secrets.html
}
```

### Dynamic Routing
```
module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/site/?ref=v0.12.0"

  name                = "DynamicRoutingVPN"
  bgp_asn             = 65000
  customer_ip         = "1.2.3.4"
  disable_bgp         = false
  route_tables        = concat(module.vpc.public_route_tables, module.vpc.private_route_tables)
  route_tables_count  = 3
  vpc_id              = module.vpc.vpc_id
  # preshared_keys      = ["XXXXXXXXXXXXX1", "XXXXXXXXXXXXX2"] #Always use aws_kms_secrets to manage sensitive information: More info: https://manage.rackspace.com/aws/docs/product-guide/iac_beta/managing-secrets.html
  # bgp_inside_cidrs    = ["169.254.18.0/30", "169.254.17.0/30"]
}
```

Full working references are available at [examples](examples)
## Limitations

- When utilizing multiple keys with the `preshared_keys` variable, terraform may have issues determining which of the VPN tunnels each applies to.  This issue is outlined at https://github.com/terraform-providers/terraform-provider-aws/issues/3359.  If this issue is encountered, it is advised to discontinue use of custom preshared keys, or to only provide a single key which would be used on both tunnels.
## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
	- vpn\_status

## Terraform 0.12 upgrade

Several resources were consolidated, taking advantage of Terraform v0.12.x features.  The following statements  
can be used to update existing resources.  In each command, `<MODULE_NAME>` should be replaced with the logic  
name used where the module is referenced.

```
terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_attributes[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_inside_cidr[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
terraform state mv module.<MODULE_NAME>.aws_vpn_connection.vpn_connection_custom_presharedkey[0] module.<MODULE_NAME>.aws_vpn_connection.vpn
```
### Module variables

The following module variables were removed as they are no longer necessary:

- `use_bgp_inside_cidrs`
- `use_preshared_keys`

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_evaluations | The number of periods over which data is evaluated to monitor VPN connection status. | `number` | `10` | no |
| alarm\_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| bgp\_asn | An existing ASN assigned to the remote network, or one of the private ASNs in the 64512 - 65534 range.  Exceptions: 7224 cannot be used in the us-east-1 region and 9059 cannot be used in eu-west-1 region. | `number` | `65000` | no |
| bgp\_inside\_cidrs | Pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. Allowed characters are alphanumeric characters and .\_. Must be between 8 and 64 characters in length and cannot start with zero (0), #Always use **aws\_kms\_key** to manage sensitive information. Use it in conjunction with variable **preshared\_keys**.  Example ["XXXX","XXXX"] | `list(string)` | `[]` | no |
| create\_customer\_gateway | Boolean value to determine if a customer gateway resource will be created. | `bool` | `true` | no |
| create\_vpn\_gateway | Boolean value to determine if a VPN gateway resource will be created. | `bool` | `true` | no |
| customer\_ip | The IP address of the Customer Endpoint.  Ignored if not creating a customer gateway. | `string` | `""` | no |
| disable\_bgp | Boolean value to determine if BGP routing protocol should be disabled for the VPN connection.  If static routes are required for this VPN this value should be set to true. | `bool` | `true` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | `string` | `"Development"` | no |
| existing\_customer\_gateway | The id of an existing customer gateway to use for the VPN.  Must be provided if not creating a customer gateway. | `string` | `""` | no |
| existing\_vpn\_gateway | The id of an existing VPN gateway to use for the VPN.  Must be provided if not creating a VPN gateway. | `string` | `""` | no |
| name | The name prefix for these IAM resources | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL) | `list(string)` | `[]` | no |
| preshared\_keys | The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. Allowed characters are alphanumeric characters and .\_. Must be between 8 and 64 characters in length and cannot start with zero (0). | `list(string)` | `[]` | no |
| route\_tables | A list of route tables to configure for route propagation. | `list(string)` | `[]` | no |
| route\_tables\_count | The number of route tables to configure for route propagation. | `number` | `0` | no |
| spoke\_vpc | Boolean value to determine if VPC is a spoke in a VPN Hub. | `bool` | `false` | no |
| static\_routes | A list of internal subnets on the customer side. The subnets must be in valid CIDR notation(x.x.x.x/x). | `list(string)` | `[]` | no |
| static\_routes\_count | The number of internal subnets on the customer side. | `number` | `0` | no |
| tags | Custom tags to apply to all resources. | `map(string)` | `{}` | no |
| vpc\_id | Provide Virtual Private Cloud ID in which the VPN resources will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| customer\_gateway | Customer Gateway ID |
| vpn\_gateway | VPN Gateway ID |

