# Providing a reference to our default VPC



# resource "aws_vpc" "fc_hdi_ecommerce_api_vpc" {
  
#   cidr_block       = "10.0.0.0/16"


#   tags = {
#     Ambiente = "dev qa hml"
#   }
# }

# resource "aws_internet_gateway" "fc_hdi_ecommerce_api_igw" {
#  vpc_id = aws_vpc.fc_hdi_ecommerce_api_vpc.id
#  tags = {
#         Ambiente = "dev qa hml"
# }
# } 



# resource "aws_subnet" "subnet_a" {

#   vpc_id     = aws_vpc.fc_hdi_ecommerce_api_vpc.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "dev"
#   }
# }

# resource "aws_subnet" "subnet_b" {
 
#   vpc_id     = aws_vpc.fc_hdi_ecommerce_api_vpc.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "dev"
#   }
# }

# resource "aws_subnet" "subnet_c" {

#   vpc_id     = aws_vpc.fc_hdi_ecommerce_api_vpc.id
#   cidr_block = "10.0.3.0/24"
#   availability_zone = "us-east-1c"

#   tags = {
#     Name = "dev"
#   }
# }

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  name        = "${var.project-prefix}-sg-${format("%s", terraform.workspace)}"
  vpc_id      = "${var.vpc-id}"
  
  ingress {
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Liberando trafedo de todas as origens
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "${var.project-prefix}-task-${format("%s", terraform.workspace)}"
  vpc_id      = "${var.vpc-id}"
  
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    # security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}