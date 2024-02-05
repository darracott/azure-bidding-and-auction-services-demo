#! /bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi
CERTS_DIR=$KMS_DIR/workspace/sandbox_common
WDIR=/workspaces/azure-bidding-and-auction-services-demo/demo

MEMBER=$1

# Read member ID from file.
MEMBER_ID=$(cat "$MEMBER".id)

# Update and retrieve KMS state digest.
echo "foo" | ccf_cose_sign1 \
  --ccf-gov-msg-type state_digest \
  --ccf-gov-msg-created_at "$(date -uIs)" \
  --signing-key "$MEMBER"_privk.pem \
  --signing-cert "$MEMBER"_cert.pem \
  --content - \
| curl https://127.0.0.1:8000/gov/members/state-digests/"$MEMBER_ID":update?api-version=2023-06-01-preview \
  --cacert $CERTS_DIR/service_cert.pem \
  -X POST \
  --data-binary @- \
  --silent \
  -H "content-type: application/cose" | jq > request.json

cat request.json

# Return signed digest to KMS to activate member.
ccf_cose_sign1 \
  --ccf-gov-msg-type ack \
  --ccf-gov-msg-created_at "$(date -uIs)" \
  --signing-key "$MEMBER"_privk.pem \
  --signing-cert "$MEMBER"_cert.pem \
  --content request.json \
| curl https://127.0.0.1:8000/gov/members/state-digests/"$MEMBER_ID":ack?api-version=2023-06-01-preview \
  -X POST \
  --cacert $CERTS_DIR/service_cert.pem \
  --data-binary @- \
  -H "content-type: application/cose"