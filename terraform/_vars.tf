variable "env" {}
variable "project" {}
variable "owner" {}
variable "region" {
  default = "ap-northeast-2"
}
#################### VPC
variable "vpc_id" {}
variable "eks_subnet_ids" {}
variable "azs" {}

#################### EKS Cluster
variable "cluster_version" {}
variable "enable_irsa" {}
variable "cluster_endpoint_private_access" {}
variable "cluster_endpoint_public_access" {}
variable "cluster_addons" {}

#################### EKS NodeGroup
variable "eks_managed_node_group_defaults" {}
variable "builders_node"{}
variable "workers_node"{}
variable "create_cloudwatch_log_group" {}
variable "node_security_group_additional_rules" {}
#################### IAM
variable "trusted_role_services" {}
variable "custom_role_policy_arns" {}
variable "additional_policy_actions" {}

variable "tags" {}