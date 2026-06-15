variable "env" {
   type = list(string)
   default = [ "dev","prod" ]
  
}

resource "aws_instance" "name" {
    ami = "ami-0d45a4eba03d1e2cf"
    instance_type = "t2.micro"
    for_each = toset(var.env)

    tags = {
      Name = each.key
  
}
}