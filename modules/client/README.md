# aws-terraform-vpn/modules/client  
AWS Client VPN is a managed client-based VPN service that enables you to securely access your AWS resources and resources in your on-premises network.  
With Client VPN, you can access your resources from any location using an OpenVPN-based VPN client.

## Basic Usage

### Client VPN
```HCL
module "vpn1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpn//modules/client/?ref=v0.12.0"

  client_vpn_cidr_block      = "192.168.10.0/24"
  private_subnet_count       = 2
  private_subnets            = [subnet_1, subnet_2]
  root_certificate_chain_arn = "arn:aws:acm:REGION:AWS_ACCOUNT:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  server_certificate_arn     = "arn:aws:acm:REGION:AWS_ACCOUNT:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  vpc_id                     = "vpc_id"

}
```

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_evaluations | The number of periods over which data is evaluated to monitor VPN connection status. | `number` | `10` | no |
| alarm\_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `number` | `60` | no |
| client\_vpn\_cidr\_block | Add the IPv4 address range, in CIDR notation, from which to assign client IP Address must be either /16 or /22 address space | `string` | n/a | yes |
| environment | The name of the environment, e.g. Production, Development, etc. | `string` | `"development"` | no |
| name | The name prefix for the VPN client resources | `string` | `"vpn-client"` | no |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL) | `list(string)` | `[]` | no |
| private\_subnet\_count | Number of private subnets in the VPC | `number` | `2` | no |
| private\_subnets | List of private subnets | `list(string)` | n/a | yes |
| public\_subnet\_count | Number of public subnets in the VPC | `number` | `0` | no |
| public\_subnets | List of public subnets | `list(string)` | `[]` | no |
| root\_certificate\_chain\_arn | The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM). | `string` | n/a | yes |
| server\_certificate\_arn | The server certificate ARN. | `string` | n/a | yes |
| tags | Custom tags to apply to all resources. | `map(string)` | `{}` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_ec2\_client\_vpn\_endpoint\_dns | client vpn end point DNS |
| aws\_ec2\_client\_vpn\_endpoint\_id | client vpn end point id |

