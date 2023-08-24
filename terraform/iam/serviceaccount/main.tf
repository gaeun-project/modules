terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }
}
locals {
  k8s_service_account_system_namespace = var.namespace
  output_eks                           = var.output_eks
  profile                              = var.profile
}

# data "aws_region" "region_name" {
#   name = var.aws_region
# }

# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
# }

module "service-accounts-eks" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name   = "${var.name}-${var.eks_cluster_name}"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = var.provider_url
      namespace_service_accounts = [local.k8s_service_account_system_namespace]
    }
  }

  tags = {
    Name = "vpc-cni-irsa"
  }
}


module "iam_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = "${var.name}-${var.eks_cluster_name}"
  path        = "/"
  description = "EKS external_dns policy in ${var.eks_cluster_name}"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  EOF
}