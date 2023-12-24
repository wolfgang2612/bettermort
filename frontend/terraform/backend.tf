terraform {
  backend "s3" {
    bucket = "tfstate-bettermort-frontend"
    key    = "tf-state"
    region = "ap-south-1"
  }
}
