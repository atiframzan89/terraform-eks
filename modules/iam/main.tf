resource "aws_iam_role" "customer-eks-iam-role" {
  name = "${var.customer}-eks-${var.environment}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["eks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# resource "aws_iam_role_policy_attachment" "customer-AmazonEKSServicePolicy" {
#   policy_arn    = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role          = aws_iam_role.customer-eks-iam-role.name

# }

resource "aws_iam_role_policy_attachment" "customer-AmazonEKSClusterPolicy" {
  policy_arn    = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role          = aws_iam_role.customer-eks-iam-role.name

}





# IAM Policy for Nodes
resource "aws_iam_role" "customer-iam-nodes-role" {
  name = "${var.customer}-eks-node-group-${var.environment}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "customer-s3-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEKSWorkerNodePolicy-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}


resource "aws_iam_role_policy_attachment" "customer-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEKSWorkerNodePolicy-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}

resource "aws_iam_role_policy_attachment" "customer-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEKS_CNI_Policy-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEC2ContainerRegistryReadOnly-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEC2ContainerRegistryReadOnly-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}

resource "aws_iam_role_policy_attachment" "customer-nodes-AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.customer-iam-nodes-role.name
#   tags          = {
#     "Name"          = "${var.customer}-AmazonEC2ContainerRegistryReadOnly-${var.environment}"
#     "Environment"   = var.environment
#     "Terraform"     = "True"

#   }
}

# Loadbalancer Controller IAM Roles and Policies
resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = var.aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller-role-${var.customer}-${var.environment}"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("${path.module}/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerControllerPolicy-${var.customer}-${var.environment}"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}




