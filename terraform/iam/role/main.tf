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
  output_eks                           = var.output_eks
  profile                              = var.profile
}

# data "aws_region" "region_name" {
#   name = var.aws_region
# }

# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
# }

module "iam-assumable-role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  create_role = var.create_role
  role_name   = "${var.name}-${var.eks_cluster_name}"
  role_requires_mfa = false
  create_instance_profile = true
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  trusted_role_services = ["ec2.amazonaws.com"]
  trusted_role_actions =["sts:AssumeRole"]

  number_of_custom_role_policy_arns = 4

  tags = {
    Name = "vpc-cni-irsa"
  }
}