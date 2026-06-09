resource "aws_instance" "name" {
    ami = "ami-029a761f237195c2c"
    instance_type = "t2.micro"
  
}

resource "aws_s3_bucket" "name" {
  bucket = "edwin-unique-mybucket-testingfordependson-12345hwvdhwv"
  depends_on = [ aws_instance.name ]
}