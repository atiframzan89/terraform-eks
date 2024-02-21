data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "eksauth" {
    name = module.eks.eks-cluster-name
}
# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# data "tls_certificate" "example" {
#   url = aws_eks_cluster.eks-cluster-name.identity.0.oidc.0.issuer
# }

data "aws_region" "current" {}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.aws-iam-openid-connect-provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [module.eks.aws-iam-openid-connect-provider.arn]
      type        = "Federated"
    }
  }
}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = [ "amazon" ]


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}