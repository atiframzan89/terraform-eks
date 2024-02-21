terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.profile
  #version = "~> 3.0"
}
provider "kubernetes" {
  host = module.eks.eks-cluster-endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate_authority)
  #token = data.aws_eks_cluster_auth.eksauth.token
  # replaced token because it giving Unauthorized Error, as EKS deployment exceeds 15min the token gets expried.
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks-cluster-id ]
      command     = "aws"
    }
  
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks-cluster-endpoint
    # cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    cluster_ca_certificate = base64decode(module.eks.certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks-cluster-id]
      command     = "aws"
    }
  }
}