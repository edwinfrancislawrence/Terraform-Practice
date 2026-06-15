resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    region = "us-west-2"
    tags = {
      Name="My_VPC"
    }
}

resource "aws_subnet" "name" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = "us-west-2a"
    tags = {
      Name ="My_Subnet"
    }
}
resource "aws_security_group" "name" {
  name        = "devops-project-veera-nit"
  description = "Allow TLS inbound traffic"

  

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow access to port ${ingress.key}"
      from_port   = ingress.key #here key is the port number and value is the source CIDR block
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
     
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG Inbound Rule Diff Source"
  }
}

resource "aws_instance" "name" {
    ami           = "ami-09e69ca1171857250"
    instance_type = "t2.micro"
    
    vpc_security_group_ids = [aws_security_group.name.id]
    subnet_id = aws_subnet.name.id
    tags = {
        Name = "my-ec2-instance(Diff SG Source)"
    }
}