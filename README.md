# Create unique, ephemeral signed SSH certificates based on a users details, when they authenticate to Boundary via Okta as the OIDC

![HashiCorp Boundary Logo](https://www.hashicorp.com/_next/static/media/colorwhite.997fcaf9.svg)

## Overview

This repo uses Okta for OIDC authentication to Boundary and takes the name of the authenticated user to create a unique, signed SSH certificate for application credential injection

## HCPb OIDC Templated SSH Certificates

This repo does the following:

1. Configures HCP Boundary.
2. Configures HCP Vault.
3. Deploy a Boundary Worker in a public network.
4. Establish a connection between the Boundary Controller and the Boundary Worker.
5. Deploy an EC2 server instance in a public subnet and is configured to trust Vault as the CA.

NOTE: 
> The fact that this repo deploys into a public subnet and therefore having a public IP attached to the targets is not supposed to mimic a production environment. This is purely to demonstrate some of the features in Boundary.

PREREQUISITES:
> To configure the necessary steps within Okta to enable the use for authenticate into Boundary, please follow the steps documented here: https://developer.hashicorp.com/boundary/tutorials/identity-management/oidc-okta

Your HCP Boundary and Vault Clusters needs to be created prior to executing the Terraform code. For people new to HCP, a trial can be utilised, which will give $50 credit to try, which is ample to test this solution.

## tfvars Variables

The following tfvars variables have been defined in a terraform.tfvars file.

- `boundary_addr`:                   = "https://xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.boundary.hashicorp.
cloud"
- `auth_method_id`:                  = "ampw_xxxxxxxxxx"                            
- `password_auth_method_login_name`: = "loginname"
- `password_auth_method_password`:   = "loginpassword"
- `aws_region`:                      = "eu-west-2"
- `availability_zone`:               = "eu-west-2b"
- `aws_vpc_cidr`:                    = "172.x.x.x/16"
- `aws_subnet_cidr`:                 = "172.31.x.x/24""
- `aws_access`:                      = ""
- `aws_secret`:                      = ""
- `vault_addr`:                      = "https://vault-cluster-address.hashicorp.cloud:8200"
- `vault_token`:                     = "hvs.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
- `okta_issuer`:                     = "https://xxx-xxxxxx.okta.com"
- `okta_client_id`:                  = "xxxxxxxxxxxxxxxxxxxx"
- `okta_client_secret`:              = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"