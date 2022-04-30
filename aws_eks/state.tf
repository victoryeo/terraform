terraform {
 backend "s3" {
   bucket         = "test-s3-store"
   key            = "remote/terraform.tfstate"
   region         = "us-west-2"
   encrypt        = false
 }
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "test-s3-store"
    key    = "remote/terraform.tfstate"
    region = "us-west-2"
  }
}