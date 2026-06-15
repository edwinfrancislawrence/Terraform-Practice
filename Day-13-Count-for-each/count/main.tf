variable "env" {
   type = list(string)
   default = [ "dev","test","prod" ]
  
}

resource "aws_instance" "name" {
    ami = "ami-0d45a4eba03d1e2cf"
    instance_type = "t2.micro"
    #count = 2
    count = length(var.env)

    tags = {
      Name = var.env[count.index]
    }
  
}