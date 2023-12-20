terraform {
  backend "s3" {
    bucket = "terraform-state-bettermort" # your-bucket-name 
    key    = "tf-state"                   # path/to/your/terraform.tfstate
    region = "ap-south-1"                 # your-region 
  }
}
