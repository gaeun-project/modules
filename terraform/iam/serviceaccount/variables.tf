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
variable "name" {
  type = string
}
variable "namespace"{
    type = string
}

