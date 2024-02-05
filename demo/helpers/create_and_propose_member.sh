#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi
CERTS_DIR=$KMS_DIR/workspace/sandbox_common
WDIR=/workspaces/azure-bidding-and-auction-services-demo/demo

NEW_MEMBER=$1

# Generate private key and certificate for new member.
./helpers/coordinator_keygenerator.sh --name "$NEW_MEMBER"

# Derive public key from private key for new member.
openssl ec -in "$NEW_MEMBER"_privk.pem -pubout > "$NEW_MEMBER"_pubk.pem
cp "$NEW_MEMBER"_privk.pem $CERTS_DIR/"$NEW_MEMBER"_privk.pem
cp "$NEW_MEMBER"_cert.pem $CERTS_DIR/"$NEW_MEMBER"_cert.pem

# Create a proposal to add the new member, formatting the cert and key to be JSON-friendly
CERTIFICATE=$(perl -pe 's/\n/\\\\n/g' < "$NEW_MEMBER"_cert.pem)
# PUBLIC_KEY=$(perl -pe 's/\n/\\\\n/g' < "$NEW_MEMBER"_pubk.pem)
cp set_member.json.template set_"$NEW_MEMBER".json
# sed -i -e "s:<PUBLIC_KEY>:$PUBLIC_KEY:g" set_"$NEW_MEMBER".json
sed -i -e "s:<CERTIFICATE>:$CERTIFICATE:g" set_"$NEW_MEMBER".json

# Must have aready run `pip install ccf`
ccf_cose_sign1 \
  --ccf-gov-msg-type proposal \
  --ccf-gov-msg-created_at "$(date -uIs)" \
  --signing-key $CERTS_DIR/member0_privk.pem \
  --signing-cert $CERTS_DIR/member0_cert.pem \
  --content set_"$NEW_MEMBER".json \
| curl https://127.0.0.1:8000/gov/members/proposals:create?api-version=2023-06-01-preview \
  --cacert $CERTS_DIR/service_cert.pem \
  --data-binary @- \
  --silent \
  -H "content-type: application/cose" \
> set_"$NEW_MEMBER".proposal.info

# Extract proposal ID and proposer ID from proposal info and write to file for later use.
jq .proposalId < set_"$NEW_MEMBER".proposal.info | sed "s:\"::g" > new_member_proposal.proposal_id 
jq .proposerId < set_"$NEW_MEMBER".proposal.info | sed "s:\"::g" > new_member_proposal.proposer_id

# Write member IDs to file for easy use later.
openssl x509 -in $CERTS_DIR/member0_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member0.id
openssl x509 -in $CERTS_DIR/member1_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member1.id
openssl x509 -in $CERTS_DIR/member2_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member2.id
openssl x509 -in "$NEW_MEMBER"_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > "$NEW_MEMBER".id

# Print summary info.
cat set_"$NEW_MEMBER".proposal.info