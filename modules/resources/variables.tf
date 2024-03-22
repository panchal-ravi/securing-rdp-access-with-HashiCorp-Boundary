variable "region" {}
variable "deployment_id" {}
variable "vpc_cidr" {}
variable "instance_type" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "boundary_version" {}
variable "boundary_cluster_id" {}
variable "vault_cluster_url" {}
variable "ad_domain" {}
variable "timezone" {}

variable "hvn" {
  type = object({
    hvn_id = string
    self_link = string
    cidr_block = string 
  })
}