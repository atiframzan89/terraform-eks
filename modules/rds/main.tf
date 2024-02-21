resource "aws_db_instance" "customer-rds" {
  allocated_storage    = 20
  db_name              = "sequent_dsp"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "seq_user"
  password             = "sequent123"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = var.customer-subnet-group
  vpc_security_group_ids = [ aws_security_group.customer-rds-security-group.id ]
  skip_final_snapshot  = true
  tags = {
    "Name"          = "${var.customer}-rds-${var.environment}"
    "Environment"   = var.environment
    "Customer"      = var.customer
    "Terraform"     = "True"
  }
}


resource "aws_security_group" "customer-rds-security-group" {
  name        = "${var.customer}-rds-${var.environment}-sg"
  description = "${var.customer}-rds-${var.environment}-sg"
  vpc_id      = var.vpc

  ingress {
    description = "rds security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ var.eks-node-group-sg ]
    # cidr_blocks = ["0.0.0.0/0"]
    # source_security_group_id = var.eks-node-group-sg
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    description = "bastion security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ var.bastion-sg-id ]
    # cidr_blocks = ["0.0.0.0/0"]
    # source_security_group_id = var.eks-node-group-sg
  }

  # egress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   cidr_blocks     = ["0.0.0.0/0"]
  # }
  tags = {
    "Name"            = "${var.customer}-eks-node-${var.environment}-sg"
    "Customer"        = var.customer
    "Environment"     = "${var.environment}"
    "Terraform"       = "True"

  }

}




