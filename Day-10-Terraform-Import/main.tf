resource "aws_instance" "name" {
  ami="ami-09e69ca1171857250"
  instance_type = "t3.micro"
  tags =  {Name="my server"}
}