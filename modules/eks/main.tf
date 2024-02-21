resource "aws_eks_cluster" "customer-eks" {
  name          = "${var.customer}-eks-cluster-${var.environment}"
  role_arn      = var.customer-eks-cluster-iam-role-arn

  vpc_config {
    subnet_ids      = var.private-subnet
    security_group_ids = [ aws_security_group.eks-node-security-group.id ]
    endpoint_public_access = true
    # subnet_ids = [
    #   aws_subnet.private-us-east-1a.id,
    #   aws_subnet.private-us-east-1b.id,
    #   aws_subnet.public-us-east-1a.id,
    #   aws_subnet.public-us-east-1b.id
    # ]
  }

  depends_on     = [ var.eks-cluster-policy, aws_security_group.eks-node-security-group ]
  tags           = {
    "Name"          = "${var.customer}-eks-${var.environment}"
    "Customer"      = var.customer
    "Environment"   = "${var.environment}"
    "Terraform"     = "True"
  } 
}


resource "aws_eks_node_group" "customer-eks-nodes" {
  cluster_name              = aws_eks_cluster.customer-eks.name
  node_group_name           = "${var.customer}-eks-node-${var.environment}"
  node_role_arn             = var.customer-iam-nodes-role-arn
  subnet_ids                = var.private-subnet
  capacity_type             = "ON_DEMAND"
  #instance_types            = [ var.eks-instance-size ]
  

#   instance_types = ["t3.small"]
  
  # remote_access {
  #   ec2_ssh_key = "aramzan-oregon"
    
  # }
  # timeouts {
  #   create = "15m"
  # } 
  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    name    = aws_launch_template.eks-node-launch-template.name
    version = aws_launch_template.eks-node-launch-template.latest_version
  }

  labels = {
    role = "general"
  }



   depends_on = [
    aws_launch_template.eks-node-launch-template,
    var.customer-nodes-AmazonEKSWorkerNodePolicy,          
    var.customer-nodes-AmazonEKS_CNI_Policy,               
    var.customer-nodes-AmazonEC2ContainerRegistryReadOnly 
    # aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    # aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    # aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]

  lifecycle {
    create_before_destroy = true
  }

  
  tags = {
    "Name"          = "${var.customer}-eks-${var.environment}"
    "Customer"      = var.customer
    "Environment"   = "${var.environment}"
    "Terraform"     = "True"
  }
}


data "tls_certificate" "eks" {
  url             = aws_eks_cluster.customer-eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.customer-eks.identity[0].oidc[0].issuer
}

resource "aws_launch_template" "eks-node-launch-template" {
  name            = "${var.customer}-eks-node-template-${var.environment}"
  key_name        = var.keypair
  instance_type            = var.eks-instance-size

# added because on eks destroy it gives dependencyViolation error
  # network_interfaces {
  #   device_index = 0
  #   delete_on_termination = true
  # }
  
  

  block_device_mappings {
    device_name   = "/dev/xvdb"

    ebs {
      volume_size = 50
      volume_type = "gp2"
    }
  }
#   user_data       = base64encode(<<-EOF
# MIME-Version: 1.0
# Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
# --==MYBOUNDARY==
# Content-Type: text/x-shellscript; charset="us-ascii"
# #!/bin/bash
# /etc/eks/bootstrap.sh your-eks-cluster
# --==MYBOUNDARY==--\
#   EOF
#   )
  lifecycle {
    create_before_destroy = true
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [ aws_security_group.eks-node-security-group.id ]
    delete_on_termination       = true
    # security_group_names             = [ aws_security_group.eks-node-security-group.name ]
    
  }
  
}

resource "aws_security_group" "eks-node-security-group" {
  name        = "${var.customer}-eks-node-${var.environment}-sg"
  description = "eks-node-security-group"
  vpc_id      = var.vpc

  ingress {
    description = "HTTP port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPs PORT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "AWS load-balancer-controller"
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubectl logs"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.20.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    "Name"            = "${var.customer}-eks-node-${var.environment}-sg"
    "Customer"        = var.customer
    "Environment"     = "${var.environment}"
    "Terraform"       = "True"

  }
  # depends_on = [
  #   aws_eks_node_group.customer-eks-nodes
  # ]
}
  
data "tls_certificate" "eks-cluster-tls" {
  url = aws_eks_cluster.customer-eks.identity.0.oidc.0.issuer
}

# resource "aws_iam_openid_connect_provider" "cluster" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks-cluster-tls.certificates.0.sha1_fingerprint]
#   url             = aws_eks_cluster.customer-eks.identity.0.oidc.0.issuer
# }


# data "template_file" "userdata" {
#   template = file("${path.module}/template/userdata.sh")
  # vars = {
  #   private_ip = var.private_ip
  #   network_lb_dns_name = var.network_lb_dns_name

  # }
# }

# Installing AWS Loadbalancer Controller through HELM
# resource "helm_release" "aws-load-balancer-controller" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.4.1"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.customer-eks.id
#   }

#   set {
#     name  = "image.tag"
#     value = "v2.4.2"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = var.aws-load-balancer-controller-role-arn
#   }

#   depends_on = [
#     aws_eks_node_group.customer-eks-nodes,
#     var.aws-load-balancer-controller-attach
#   ]
# }

# Creating an S3 bucket
# resource "aws_s3_bucket" "customer-s3-bucket"{
#   bucket = "${var.s3-bucket-name}"
#   # region = "${var.region}"

#   tags = {
#     "Name"            = "${var.customer}-s3-${var.environment}"
#     "Customer"        = var.customer
#     "Environment"     = "${var.environment}"
#     "Terraform"       = "True"
# }
# }

# Public Access S3 Bucket

# resource "aws_s3_bucket_public_access_block" "customer-s3-public-access" {
#   bucket = aws_s3_bucket.customer-s3-bucket.id

#   # block_public_acls   = true
#   # block_public_policy = true
# }

# public S3 bucket

# resource "aws_s3_bucket_acl" "customer-public-s3-acl" {
#   bucket = aws_s3_bucket.customer-s3-bucket.id
#   acl    = "public-read"
# }

# # Creating VPC Endpoint S3

# resource "aws_vpc_endpoint" "customer-vpc-endpoint-s3" {
#   vpc_id       = var.vpc
#   service_name = "com.amazonaws.${var.region}.s3"

# }

# resource "aws_vpc_endpoint_route_table_association" "customer-vpc-endpoint-rt-association" {
#   route_table_id  = var.private-rt
#   vpc_endpoint_id = aws_vpc_endpoint.customer-vpc-endpoint-s3.id
# }