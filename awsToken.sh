#!/usr/bin/env bash
#
# Based on https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2

# Fill these in with your settings/preferences
AWS_USER_PROFILE=
ARN_OF_MFA=
DEFAULT_REGION=eu-central-1
OUTPUT=yaml
AWS_2AUTH_PROFILE=2auth
DURATION=129600

AWS_CLI=`which aws`
if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed, exiting."
  exit 1
fi

MFA_TOKEN_CODE=$1
if [ $# -ne 1 ]; then
  echo "Usage: $0  <MFA_TOKEN_CODE>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = Code from MFA device"
  exit 2
fi

echo "Connecting..."

read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$(aws --profile $AWS_USER_PROFILE sts get-session-token \
  --duration $DURATION  \
  --serial-number $ARN_OF_MFA \
  --token-code $MFA_TOKEN_CODE \
  --output text | awk '{ print $2, $4, $5 }')
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error getting key. Check your credentials!"
  exit 1
fi
echo "Setting up environment for profile $AWS_2AUTH_PROFILE in region $DEFAULT_REGION..."
`aws --profile $AWS_2AUTH_PROFILE configure set region "$DEFAULT_REGION"`
`aws --profile $AWS_2AUTH_PROFILE configure set output "$OUTPUT"`
`aws --profile $AWS_2AUTH_PROFILE configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"`
`aws --profile $AWS_2AUTH_PROFILE configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"`
`aws --profile $AWS_2AUTH_PROFILE configure set aws_session_token "$AWS_SESSION_TOKEN"`
echo "Authenticated successfully! Remeber to set your profile with:  export AWS_DEFAULT_PROFILE=$AWS_2AUTH_PROFILE"
