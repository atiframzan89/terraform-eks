variable "customer" {}
variable "environment" {}
variable "public-subnet" {}
# variable "public-subnet-2" {}
variable "private-subnet" {}
# variable "private-subnet-2" {}
variable "eks-cluster-policy" {}
variable "vpc" {}
variable "customer-eks-cluster-iam-role-arn" {}
variable "customer-iam-nodes-role-arn" {}
variable "eks-instance-size" {}
variable "keypair" {}
variable "customer-nodes-AmazonEKSWorkerNodePolicy" {}
variable "customer-nodes-AmazonEKS_CNI_Policy" {}
variable "customer-nodes-AmazonEC2ContainerRegistryReadOnly" {}
variable "region" {}
variable "aws-load-balancer-controller-role-arn" {}
variable "aws-load-balancer-controller-attach" {}
#variable "s3-bucket-name" {}        
variable "private-rt" {}
 variable "profile" {
  
 }
