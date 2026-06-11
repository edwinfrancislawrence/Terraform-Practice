module "s3_bucket" {
    source = "github.com/edwinfrancislawrence/terraform-aws-s3-bucket.git"
    
    bucket  = var.S3_name # 👈 Change to your globally unique name
    

  control_object_ownership = var.control_object_ownership
  

  versioning = {
    enabled = var.versioning # 👈 Automatically enables version protection
  }
  
}