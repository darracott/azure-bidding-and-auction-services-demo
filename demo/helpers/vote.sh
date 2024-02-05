#! /bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Set up voter's details.
VOTE=$1
VOTER=$2
VOTER_ID=$(cat "$VOTER".id)
PROPOSAL_ID=$3

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi
CERTS_DIR=$KMS_DIR/workspace/sandbox_common
WDIR=/workspaces/azure-bidding-and-auction-services-demo/demo

if [ $# -ne 3 ]; then
    echo "Usage: $0 [accept|reject] MEMBER_NAME PROPOSAL_ID"
    echo "Example: $0 accept member0 abc123def456..."
    exit 1
fi

if [ "$VOTE" == "accept" ] || [ "$VOTE" == "reject" ]; then
    echo "$VOTER voting $VOTE on proposal $PROPOSAL_ID"
else
    echo "Invalid usage: \"$VOTE\" should be either \"accept\" or \"reject\"."
    exit 1
fi

# Votes yes on the proposal to add member4.
ccf_cose_sign1 \
  --ccf-gov-msg-type ballot \
  --ccf-gov-msg-created_at "$(date -uIs)" \
  --ccf-gov-msg-proposal_id "$PROPOSAL_ID" \
  --signing-key $CERTS_DIR/"$VOTER"_privk.pem \
  --signing-cert $CERTS_DIR/"$VOTER"_cert.pem \
  --content vote_"$VOTE".json \
| curl https://127.0.0.1:8000/gov/members/proposals/"$PROPOSAL_ID"/ballots/"$VOTER_ID":submit?api-version=2023-06-01-preview \
  --cacert $CERTS_DIR/service_cert.pem \
  --data-binary @- \
  -H "content-type: application/cose"