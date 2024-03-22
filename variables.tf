variable "hcp_client_id" {}
variable "hcp_client_secret" {}
variable "hcp_boundary_admin" {}
variable "hcp_boundary_password" {}

variable "boundary_tier" {
  description = "The tier that the HCP Boundary cluster will be provisioned as, 'Standard' or 'Plus'."
  default     = "Plus"
}

variable "vault_tier" {
  description = "Tier of the HCP Vault cluster. Refer https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/vault_cluster for valid values"
  default     = "dev"
}

variable "ad_domain" {
  description = "Windows domain name to setup the domain controller"
  default     = "hashidemo.com"
}

variable "aws_region" {
  description = "AWS region to deploy infrastructure and HCP Vault"
  default     = "ap-southeast-1"
}

variable "aws_instance_type" {
  description = "AWS instance size"
  default     = "t3.micro"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.200.0.0/16"
}

variable "aws_public_subnets" {
  description = "AWS public subnet CIDR."
  type        = list(any)
  default     = ["10.200.10.0/24"]
}

variable "aws_private_subnets" {
  description = "AWS private subnet CIDR"
  type        = list(any)
  default     = ["10.200.20.0/24"]
}

variable "boundary_version" {
  description = "Boundary version for self-managed worker. Please note this should match HCP Boundary Cluster version"
  default     = "0.15.2+ent"
}
variable "timezone" {
  description = "Timezone for Windows Domain Controller and Windows Client Machine"
  default     = "Singapore Standard Time"
}
