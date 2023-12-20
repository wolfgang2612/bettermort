# How to deploy

- Create S3 bucket for terraform state management

  `terraform-state-bettermort`

- Create IAM user with the following permissions:

  S3 policy:

  ```
      {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Effect": "Allow",
                  "Action": [
                      "s3:*"
                  ],
                  "Resource": [
                      "arn:aws:s3:::bettermort",
                      "arn:aws:s3:::terraform-state-bettermort",
                      "arn:aws:s3:::bettermort/*",
                      "arn:aws:s3:::terraform-state-bettermort/*"
                  ]
              }
          ]
      }
  ```

  IAM policy:

  ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "iam:GetUser",
                "Resource": "arn:aws:iam::{account_id}:user/bettermort"
            }
        ]
    }
  ```

- Create access key for this user and store it in the `~/.aws/credentials` file under the appropriate profile name (not the best practice, but its ok for now)

- Run terraform commands

  ```
  export AWS_PROFILE={aws_profile_name}
  terraform init
  terraform plan
  terraform apply
  ```

- Push changes to `main` branch - the GHA will sync the `out` folder to the S3 bucket

##

# Output

http://bettermort.s3-website.ap-south-1.amazonaws.com/
