output "eks-cluster-endpoint" {
    value = aws_eks_cluster.customer-eks.endpoint
}

output "certificate_authority" {
    value = aws_eks_cluster.customer-eks.certificate_authority[0].data
}

output "eks-cluster-name" {
    value = aws_eks_cluster.customer-eks.name
}

output "aws-iam-openid-connect-provider" {
  value = aws_iam_openid_connect_provider.eks
}

output "eks-cluster-id" {
    value = aws_eks_cluster.customer-eks.id
}

output "eks-node-group-sg" {
    value = aws_security_group.eks-node-security-group.id
  
}

