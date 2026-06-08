resource "aws_instance" "name" {
    ami = "ami-029a761f237195c2c"
    instance_type = "t2.micro"
    tags = {Name="test"}
  
#   lifecycle {
#     create_before_destroy = true
#   }
  lifecycle {
    prevent_destroy = true
  }
#   lifecycle {
#     ignore_changes = [ tags, ]
#   }
}
