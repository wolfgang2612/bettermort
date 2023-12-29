# How to deploy

- Create S3 bucket for terraform state management

  ```
  tfstate-bettermort-backend
  tfstate-bettermort-frontend
  ```

- Create IAM user with policies in aws_init/policies folder

  `It is vital to create resources starting with the name 'bettermort' - the policies are granular to the extent of checking arnlike starting with 'bettermort*'`

- Create access key for this user and store it in the `~/.aws/credentials` file under the appropriate profile name (not the best practice, but its ok for now)

- Run terraform commands

  ```
  export AWS_PROFILE={aws_profile_name}
  terraform init
  terraform plan
  terraform apply
  ```

- Push changes to `main` branch - the GHA will sync the `frontend/out` folder to the S3 bucket

##

# Output

http://bettermort.s3-website.ap-south-1.amazonaws.com/
