variable "hcp_client_id" {
  sensitive   = true
  type        = string
  description = "The OAuth2 Client ID for API operations."
}
variable "hcp_client_secret" {
  sensitive   = true
  type        = string
  description = "The OAuth2 Client Secret for API operations."
}
variable "hcp_boundary_admin" {
  type        = string
  description = "The username of the initial admin user. This must be at least 3 characters in length, alphanumeric, hyphen, or period."
}
variable "hcp_boundary_password" {
  sensitive   = true
  type        = string
  description = "The password of the initial admin user. This must be at least 8 characters in length."
}

variable "boundary_tier" {
  description = "The tier that the HCP Boundary cluster will be provisioned as, 'Standard' or 'Plus'."
  type        = string
  default     = "Plus"
}

variable "vault_tier" {
  description = "Tier of the HCP Vault cluster. Refer https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/vault_cluster for valid values"
  type        = string
  default     = "dev"
}

variable "ad_domain" {
  description = "Windows domain name to setup the domain controller"
  type        = string
  default     = "hashidemo.com"
}

variable "aws_region" {
  description = "AWS region to deploy infrastructure and HCP Vault"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_instance_type" {
  description = "AWS instance size"
  type        = string
  default     = "t3.micro"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.200.0.0/16"
}

variable "aws_public_subnets" {
  description = "AWS public subnet CIDR."
  type        = list(string)
  default     = ["10.200.10.0/24"]
}

variable "aws_private_subnets" {
  description = "AWS private subnet CIDR"
  type        = list(string)
  default     = ["10.200.20.0/24"]
}
variable "boundary_version" {
  description = "Boundary version for self-managed worker. Please note this should match HCP Boundary Cluster version"
  type        = string
  default     = "0.15.2+ent"
}
variable "timezone" {
  description = "Timezone for Windows Domain Controller and Windows Client Machine"
  type        = string
  default     = "Singapore Standard Time"
}
