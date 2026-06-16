resource "aws_instance" "example" {
  ami           = "ami-09e69ca1171857250"
  instance_type = "t2.micro"

  tags = {
    Name = "My-EC2-Instance"
  }
}