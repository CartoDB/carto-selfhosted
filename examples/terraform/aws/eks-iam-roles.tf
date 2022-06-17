data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
}

locals {
  role_to_user_map = {
    EksAdmin     = "admin",
    EksDeveloper = "developer"
  }

  role_map_users = [
    for role_name, user in local.role_to_user_map : {
      rolearn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${role_name}"
      username = user
      groups   = (user == "admin") ? ["system:masters"] : ["none"]
    }
  ]
}

resource "aws_iam_role" "admin" {
  name                 = "EksAdmin"
  max_session_duration = 43200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.assume_admin_role
        }
      },
    ]
  })

  inline_policy {
    name = "eks_admin_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "developer" {
  name                 = "EksDeveloper"
  max_session_duration = 43200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.assume_developer_role
        }
      },
    ]
  })

  inline_policy {
    name = "eks_developer_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:DescribeCluster"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

# create the IAM OIDC provider for the cluster
resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

#resource "aws_iam_role" "eks-service-account-role" {
#  name = "workload_sa"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Action = ["sts:AssumeRoleWithWebIdentity"]
#        Effect = "Allow"
#        Sid    = ""
#        Principal = {
#          Federated = aws_iam_openid_connect_provider.eks-cluster.arn
#        }
#      },
#    ]
#  })
#
#  inline_policy {
#    name = "eks_service_account_policy"
#
#    policy = jsonencode({
#      Version = "2012-10-17"
#      Statement = [
#        {
#          Action   = ["s3:GetBucket", "s3:GetObject", "s3:PutObject"]
#          Effect   = "Allow"
#          Resource = "*"
#        },
#      ]
#    })
#  }
#}

