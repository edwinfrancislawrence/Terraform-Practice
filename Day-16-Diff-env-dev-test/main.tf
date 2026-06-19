resource "aws_s3_bucket" "name" {
    bucket = "rctvybunimxvbn"
    provider = aws.dev_nit
  
}

resource "aws_s3_bucket" "name-2" {
    bucket = "bhscdgsvhs"
    provider = aws.test_nit
  
}
resource "aws_s3_bucket" "name-2" {
    bucket = "bhscdgsvhs"
    provider = aws.prod_nit
  
}