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
# variable "name" {
#   type = string
# }
# variable "namespace"{
#     type = string
# }
variable "create_role"{
    type = bool
    default =false
}
variable "account_id"{
    type = string  
}
variable "iam_service"{
    type = map(string)


}