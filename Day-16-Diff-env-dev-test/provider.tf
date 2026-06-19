provider "aws" {
    region = "us-east-1"
    profile = "dev"
    alias = "dev_nit"
    
  
}

provider "aws" {
    region = "us-west-2"
    profile = "test"
    alias = "test_nit"
  
}
provider "aws" {
    region = "us-west-2"
    profile = "prod"
    alias = "prod_nit"
  
}