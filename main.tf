module "vpc" {
    source                  = "./modules/vpc"
    vpc                     = var.vpc
    az                      = data.aws_availability_zones.available.names
    environment             = var.environment
    customer                = var.customer

}

module "eks" {
    source                                              = "./modules/eks"
    region                                              = var.region
    depends_on                                          = [ module.vpc ]
    environment                                         = var.environment
    customer                                            = var.customer
    public-subnet                                       = [ module.vpc.public-subnet-1, module.vpc.public-subnet-2 ]
    private-subnet                                      = [ module.vpc.private-subnet-1, module.vpc.private-subnet-2 ]
    vpc                                                 = module.vpc.vpc-id
    eks-cluster-policy                                  = module.iam.customer-eks-cluster-iam-role-arn
    customer-eks-cluster-iam-role-arn                   = module.iam.customer-eks-cluster-iam-role-arn
    customer-iam-nodes-role-arn                         = module.iam.customer-iam-nodes-role-arn
    eks-instance-size                                   = var.eks-instance-size
    keypair                                             = var.keypair
    customer-nodes-AmazonEKSWorkerNodePolicy            = module.iam.customer-nodes-AmazonEKSWorkerNodePolicy
    customer-nodes-AmazonEKS_CNI_Policy                 = module.iam.customer-nodes-AmazonEKS_CNI_Policy
    customer-nodes-AmazonEC2ContainerRegistryReadOnly   = module.iam.nodes-AmazonEC2ContainerRegistryReadOnly
    aws-load-balancer-controller-role-arn               = module.iam.aws-load-balancer-controller-role-arn
    aws-load-balancer-controller-attach                 = module.iam.aws-load-balancer-controller-attach
#    s3-bucket-name                                      = var.s3-bucket-name
    private-rt                                          = module.vpc.private-rt
    profile                                             = var.profile
                          
}

module "iam" {
    source                          = "./modules/iam"
    environment                     = var.environment
    customer                        = var.customer
    aws_load_balancer_controller_assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy
    # aws-iam-openid-connect-provider = module.eks.aws-iam-openid-connect-provider
    
}

# module "rds" {
#     source                          = "./modules/rds"
#     environment                     = var.environment
#     customer                        = var.customer
#     vpc                             = module.vpc.vpc-id
#     customer-subnet-group           = module.vpc.customer-subnet-group
#     eks-node-group-sg               = module.eks.eks-node-group-sg
#     bastion-sg-id                   = module.bastion.bastion-sg-id
    
    

# }

module "bastion" {
    source                          = "./modules/bastion"
    environment                     = var.environment
    customer                        = var.customer
    vpc                             = module.vpc.vpc-id
    internet-gateway-id             = module.vpc.internet-gateway-id
    public-subnet                   = module.vpc.public-subnet-1
    amazon-linux-2                  = data.aws_ami.amazon-linux-2
    keypair                         = var.keypair
    
    #depends_on                      = [ module.rds ]
}