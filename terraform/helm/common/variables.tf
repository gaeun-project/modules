variable "name" {
  type = string
}

variable "aws_load_balancer_controller_values" {
  default = {}
}

variable "aws_load_balancer_controller_version" {
  default = "1.4.7"
}

variable "external_dns_zones" {
  type = list(string)
}

variable "external_dns_values" {
  default = {}
}

variable "external_dns_version" {
  default = "6.13.1"
}

variable "tags" {
  default = {}
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}
variable "output_eks" {
  default = {}
}
variable "profile" {
  type = string
}

variable "provider_url" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}