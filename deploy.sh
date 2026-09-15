#!/usr/bin/env bash
set -euo pipefail

: "${BUCKET_NAME:?Terraform debe proporcionar BUCKET_NAME}"
: "${AWS_REGION:?Terraform debe proporcionar AWS_REGION}"

project_dir="$(cd "$(dirname "$0")" && pwd)"
policy_file="$(mktemp)"
trap 'rm -f "$policy_file"' EXIT

if ! aws s3api get-bucket-location --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
    --create-bucket-configuration "LocationConstraint=$AWS_REGION"
fi

aws s3api put-public-access-block --bucket "$BUCKET_NAME" \
  --public-access-block-configuration '{"BlockPublicAcls":true,"IgnorePublicAcls":true,"BlockPublicPolicy":false,"RestrictPublicBuckets":false}'
aws s3api put-bucket-website --bucket "$BUCKET_NAME" \
  --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}'

sed "s/\${bucket_name}/$BUCKET_NAME/g" "$project_dir/bucket-policy.json.tftpl" > "$policy_file"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "file://$policy_file"
aws s3 cp "$project_dir/index.html" "s3://$BUCKET_NAME/index.html" --content-type 'text/html; charset=utf-8'
aws s3 cp "$project_dir/style.css" "s3://$BUCKET_NAME/style.css" --content-type 'text/css; charset=utf-8'
aws s3 cp "$project_dir/js/app.js" "s3://$BUCKET_NAME/js/app.js" --content-type 'application/javascript; charset=utf-8'
