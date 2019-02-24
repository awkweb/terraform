#!/bin/bash
# Based on https://github.com/terraform-providers/terraform-provider-aws/issues/632#issuecomment-388152004

# Exit if any of the intermediate steps fail
set -e

# Extract "repository_name" argument from the input into
# REPOSITORY_NAME shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "REPOSITORY_NAME=\(.repository_name)"')"

# Get most recent image
# Based on https://www.timcosta.io/aws-cli-get-most-recent-image-in-ecr/
TAG="$(aws ecr describe-images \
--repository-name ${REPOSITORY_NAME} \
--output text \
--query 'sort_by(imageDetails,& imagePushedAt)[*].imageTags[*]' \
| tr '\t' '\n' \
| tail -1)"

# Generate a JSON object containing image tag
jq -n --arg TAG "$TAG" '{"tag":$TAG}'

exit 0