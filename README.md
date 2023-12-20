# How to deploy

- Run terraform commands

  ```
  export AWS_PROFILE={aws_profile_name} (or change values in provider.tf)
  terraform init
  terraform plan
  terraform apply
  ```

- Push changes to `main` branch - the GHA will sync the `out` folder to the S3 bucket
