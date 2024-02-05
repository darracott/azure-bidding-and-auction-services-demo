#!/bin/bash

MEMBER_ID=$(cat $1.id)

curl https://127.0.0.1:8000/gov/members/proposals?api-version=2023-06-01-preview -k -s | \
jq -r '.value[] | select(.proposalState=="Open") | .proposalId' | ./_poll.sh $MEMBER_ID


