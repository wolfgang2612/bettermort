#!/bin/bash

terraform init
terraform apply -auto-approve

API_ID=$(terraform output -raw api_id)
STAGE=$(terraform output -raw stage)

sed -i "" -e "s/API_ID = .*/API_ID = \"$API_ID\"/" ../lambda/layer/python/constants.py
sed -i "" -e "s/STAGE = .*/STAGE = \"$STAGE\"/" ../lambda/layer/python/constants.py

terraform apply -auto-approve
