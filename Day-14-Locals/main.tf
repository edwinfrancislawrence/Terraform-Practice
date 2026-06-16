locals {
  region = "us-west-2"
  instance_type = "t2.micro"
  ami_id = "ami-09e69ca1171857250"
}

resource "aws_instance" "name" {
  ami = local.ami_id
  instance_type = local.instance_type
  region = local.region
}