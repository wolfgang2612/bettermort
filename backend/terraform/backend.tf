terraform {
  backend "s3" {
    bucket = "tfstate-bettermort-backend"
    key    = "tf-state"
    region = "ap-south-1"
  }
}
