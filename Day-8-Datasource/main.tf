data "aws_subnet" "name" {
    filter {
    name   = "tag:Name"
    values = ["Dev"] # insert value here
  }
}

resource "aws_instance" "name" {
    ami="ami-029a761f237195c2c"
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.name.id

}