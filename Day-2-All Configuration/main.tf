resource "aws_instance" "name" {
    ami= var.ami_id
    tags = var.Name
    instance_type = var.instance_type
  
}