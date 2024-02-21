region = "us-east-2"
vpc = {
    #name = "vpc"
    cidr                    = "13.20.0.0/16"
    public_subnet           = ["13.20.1.0/24", "13.20.2.0/24", "13.20.3.0/24" ]
    private_subnet          = ["13.20.4.0/24", "13.20.5.0/24", "13.20.6.0/24" ]
}
customer                    = "ioh"
environment                 = "staging"
eks-instance-size           = "t2.medium"  
keypair                     = "ioh-dev-infra"
#s3-bucket-name              = "ioh-eks-prod"
profile                     = "ioh"