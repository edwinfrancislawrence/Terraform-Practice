module "VPC" {
  source       = "./Modules/VPC"
  cidr_block   = "10.0.0.0/16"
  subnet_1_cidr  = "10.0.1.0/24"
  subnet_2_cidr = "10.0.2.0/24"
  az1           = "us-east-1a"
  az2           = "us-east-1b"
}

module "EC2" {
    source = "./Modules/EC2"
    ami_id = "ami-09e69ca1171857250"
    instance_type = "t2.micro"
    subnet_1_id = module.VPC.subnet_1_id
        
    
  
}

module "rds" {
  source         = "./Modules/RDS"
  subnet_1_id      = module.VPC.subnet_1_id
  subnet_2_id      = module.VPC.subnet_2_id
  instance_class = "db.t3.micro"
  db_name        = "mydb"
  db_user        = "admin"
  db_password    = "Admin12345"
}

module "s3" {
    source = "./Modules/S3"
    bucket = "wertyuisdfghjxcfvgh"
  

}

module "lambda" {
    source = "./Modules/Lambda"
}