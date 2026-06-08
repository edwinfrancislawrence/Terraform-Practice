terraform {
  backend "s3" {
    bucket         = "edwintfstatefiletesting"
    key            = "terraform.tfstate"      # The path inside the bucket where the file will sit
    region         = "us-west-2"                  # The region where your bucket lives
    encrypt        = true                         # Encrypts the state file at rest
    use_lockfile   = true                         # S3 native locking to prevent concurrent modification
  }
}