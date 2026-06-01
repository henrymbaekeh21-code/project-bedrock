# ============================================================================
# IAM Module — bedrock-dev-view user + RBAC
# ============================================================================

# Developer IAM User
resource "aws_iam_user" "dev" {
  name = "bedrock-dev-view"

  tags = {
    Name    = "bedrock-dev-view"
    Project = "karatu-2025-capstone"
  }
}

# Console access password
resource "aws_iam_user_login_profile" "dev" {
  user                    = aws_iam_user.dev.name
  password_length         = 16
  password_reset_required = false
}

# Access Keys for CLI
resource "aws_iam_access_key" "dev" {
  user = aws_iam_user.dev.name
}

# ReadOnlyAccess for AWS Console
resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.dev.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Custom policy for S3 PutObject on assets bucket
resource "aws_iam_user_policy" "s3_put" {
  name = "bedrock-s3-assets-put"
  user = aws_iam_user.dev.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
    }]
  })
}

# EKS access policy (for kubectl via IAM)
resource "aws_iam_policy" "eks_access" {
  name        = "bedrock-eks-access"
  description = "Allow EKS cluster access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ]
      Resource = var.cluster_arn
    }]
  })
}

resource "aws_iam_user_policy_attachment" "eks_access" {
  user       = aws_iam_user.dev.name
  policy_arn = aws_iam_policy.eks_access.arn
}

# Kubernetes RBAC — map IAM user to 'view' ClusterRole
resource "kubernetes_cluster_role_binding" "dev_view" {
  metadata {
    name = "bedrock-dev-view-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "User"
    name      = aws_iam_user.dev.arn
    api_group = "rbac.authorization.k8s.io"
  }
}

# AWS Load Balancer Controller IAM Role (IRSA)
resource "aws_iam_role" "alb_controller" {
  name = "bedrock-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_arn, "/arn:aws:iam::[0-9]+:oidc-provider//", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}
