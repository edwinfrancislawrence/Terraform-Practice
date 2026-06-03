resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.Instance_type
    tags = {Name=var.name}
}