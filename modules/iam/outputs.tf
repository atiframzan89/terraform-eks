output "customer-eks-cluster-iam-role-arn" {
    value = aws_iam_role.customer-eks-iam-role.arn
}

output "customer-amazon-eks-cluster-policy" {
    value = aws_iam_role_policy_attachment.customer-AmazonEKSClusterPolicy
}

output "customer-iam-nodes-role-arn" {
    value = aws_iam_role.customer-iam-nodes-role.arn
}

output "customer-nodes-AmazonEKSWorkerNodePolicy" {
    value = aws_iam_role_policy_attachment.customer-nodes-AmazonEKSWorkerNodePolicy
}

output "customer-nodes-AmazonEKS_CNI_Policy" {
    value = aws_iam_role_policy_attachment.customer-nodes-AmazonEKS_CNI_Policy
}

output "nodes-AmazonEC2ContainerRegistryReadOnly" {
    value = aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
}

# Loadbalancer Controller ARN
output "aws-load-balancer-controller-role-arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws-load-balancer-controller-attach" {
  value = aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
}