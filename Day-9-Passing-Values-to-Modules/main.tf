module "Dev" {
    source = "../Day-9-Modules"
    ami_id = "ami-029a761f237195c2c"
    instance_type = "t2.micro"
    name="Testing Modules"
  
}