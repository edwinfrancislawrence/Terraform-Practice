module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2" # 👈 Uses a stable, verified version

  bucket = "edwintestingmodulebucket-2026" # 👈 Change to your globally unique name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true # 👈 Automatically enables version protection
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
