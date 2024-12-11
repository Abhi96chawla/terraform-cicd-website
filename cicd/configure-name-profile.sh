#!/bin/bash

# Exit script if any command fails
set -eu

# Configure AWS named profile
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_REGION

# Verify that the profile is configured
#aws configure list --profile $PROFILE_NAME
