terraform {
  backend "s3" {
    bucket         = "edwintfstatefiletesting"
    key            = "dev/terraform.tfstate"      # The path inside the bucket where the file will sit
    region         = "us-east-1"                  # The region where your bucket lives
    encrypt        = true                         # Encrypts the state file at rest
  }
}