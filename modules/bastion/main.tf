resource "aws_instance" "customer-bastion" {
 depends_on = [ var.internet-gateway-id ]


 ami                                    = var.amazon-linux-2.id
 associate_public_ip_address            = true
#  iam_instance_profile                   = "${aws_iam_instance_profile.test.id}"
 instance_type                          = "t2.micro"
 key_name                               = var.keypair
#  vpc_security_group_ids                 = ["${aws_security_group.test.id}"]
 security_groups                        = [ aws_security_group.ec2-sg.id ]
 subnet_id                              = var.public-subnet
 #user_data                              = data.template_file.userdata.rendered
}


resource "aws_security_group" "ec2-sg" {
  name        = "${var.customer}-bastion-${var.environment}-sg"
  description = "${var.customer}-bastion-${var.environment}-sg"
  vpc_id      = var.vpc

  ingress {
    description = "Allow SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    # security_groups = [ var.eks-node-group-sg ]
    cidr_blocks = ["0.0.0.0/0"]
    # source_security_group_id = var.eks-node-group-sg
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    "Name"            = "${var.customer}-bastion-${var.environment}-sg"
    "Customer"        = var.customer
    "Environment"     = "${var.environment}"
    "Terraform"       = "True"

  }

}

