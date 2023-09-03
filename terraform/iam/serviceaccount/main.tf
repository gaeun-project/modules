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
  # k8s_service_account_system_namespace = var.namespace
  output_eks                           = var.output_eks
  profile                              = var.profile
}

# data "aws_region" "region_name" {
#   name = var.aws_region
# }

# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
# }

module "iam_service_account" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  create_role = var.create_role
  for_each =  var.iam_service
  role_name   = "${each.key}-${var.eks_cluster_name}"

  # attach_vpc_cni_policy = true
  # vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${var.account_id}:oidc-provider/${var.provider_url}"
      namespace_service_accounts = ["${each.value}"]
    }
  }
  tags = {
    Name = "vpc-cni-irsa"
  }

}

module "iam_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  # 이거 나중에 시간있으면 바꾸기(pending)
  name        = "policy-${var.eks_cluster_name}"
  path        = "/"
  description = "EKS external_dns policy in ${var.eks_cluster_name}"

  policy = <<-EOF
  {
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/karpenter.sh/provisioner-name": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${var.account_id}:role/KarpenterNodeRole-${var.eks_cluster_name}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:ap-northeast-2:${var.account_id}:cluster/${var.eks_cluster_name}",
            "Sid": "EKSClusterEndpointLookup"
        },
        {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      }
    ],
      "Version": "2012-10-17"
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  for_each =  var.iam_service

  role       = "${each.key}-${var.eks_cluster_name}"# IAM 역할 이름 참조
  policy_arn = module.iam_policy.arn                     # IAM 정책 ARN 참조

  depends_on = [module.iam_service_account] 
}