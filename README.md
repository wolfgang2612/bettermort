# How to deploy

- Create S3 buckets for terraform state management.

  ```
  tfstate-bettermort-backend
  tfstate-bettermort-frontend
  ```

- Create IAM user with policies in aws/policies folder.

  - > :warning: It is vital to create resources starting with the name 'bettermort' - the policies are granular to the extent of checking arnlike starting with 'bettermort'.

  - Replace account_id with actual account ID.

- Create access key for this user and store it in the `~/.aws/credentials` file under the appropriate profile name.

- Run terraform commands

  ```
  export AWS_PROFILE={aws_profile_name}
  terraform init
  terraform plan
  terraform apply
  ```

- Push changes to `main` branch - the GHA will build the Next app and sync the `frontend/out` folder to the S3 bucket. Store the same access key and secret access key used for the profile above in Github secrets for this action.

##

# Output

http://bettermort.s3-website.ap-south-1.amazonaws.com/
