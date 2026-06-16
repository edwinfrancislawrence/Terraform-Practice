resource "aws_instance" "name" {
    ami = "ami-09e69ca1171857250"
    instance_type = "t2.micro"
    tags = {
        Name = "MyInstance"
    }
}

resource "aws_s3_bucket" "name" {
    bucket = "edwin-target-resource-testing"
    
  
}