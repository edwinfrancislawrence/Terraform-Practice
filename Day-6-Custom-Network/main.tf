#Creation of VPC
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {Name = "Dev_VPC"}
  
}

resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-west-2a"
    tags = {Name = "Dev_Subnet 1"}
  
}

resource "aws_subnet" "name2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2b"
    tags = {Name = "Dev_Subnet 2"}
  
}

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.name.id
    tags = {Name = "Dev_IG"}
  
}

resource "aws_route_table" "name" {
    vpc_id = aws_vpc.name.id
    tags = {Name ="Dev_RT"}
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.name.id
    }
  
}

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.name.id
    route_table_id = aws_route_table.name.id
  
}

resource "aws_security_group" "name" {
    name = "Dev_SG"
    description = "Allow SSH and HTTP traffic"
    vpc_id = aws_vpc.name.id

    ingress {
        from_port = 22
        to_port =  22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0" ]
    }
  
}

resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.name.id
    vpc_security_group_ids = [aws_security_group.name.id]
    tags = {Name =var.name}
  
}

# Add this missing block to create the Elastic IP
resource "aws_eip" "example" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.name]
  tags       = { Name = "Dev_NAT_EIP" }
}


resource "aws_nat_gateway" "name" {
  allocation_id = aws_eip.example.id      # ⚠️ Ensure your aws_eip block is named "example"
  subnet_id     = aws_subnet.name2.id       # Aligned to your existing public subnet name

  tags = {
    Name = "gw NAT"
  }

  # Dependencies ensure resources build in the correct order
  depends_on = [aws_internet_gateway.name] # Aligned to your existing IGW name
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.name.id                 # Aligned to your existing VPC name
  tags   = { Name = "Dev_Private_RT" }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id # Aligned to the NAT GW resource above
  }
}

resource "aws_route_table_association" "name2" {
    subnet_id = aws_subnet.name2.id
    route_table_id = aws_route_table.private_rt.id
  
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "edwintestingcustomnetwork"

  tags = {
    Name        = "Edwintestingcustomnetwork"
    Environment = "Dev"
  }
}


