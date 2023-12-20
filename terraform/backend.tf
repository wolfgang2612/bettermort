terraform {
  backend "s3" {
    bucket = "terraform-state-bettermort"
    key    = "tf-state"
    region = "ap-south-1"
  }
}
