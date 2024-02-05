#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

set -euo pipefail

function usage {
    echo ""
    echo "Submit a ccf proposal."
    echo ""
    echo "usage: ./submit_proposal.sh --network-url string --certificate-dir <workspace/sandbox_common> string --proposal-file string --member-count number"
    echo ""
    echo "  --network-url           string      ccf network url (example: https://test.confidential-ledger.azure.com)"
    echo "  --certificate-dir       string      The directory where the certificates are"
    echo "  --proposal-file         string      path to any governance proposal to submit (example: dist/set_js_app.json)"
    echo ""
    exit 0
}

function failed {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}

# parse parameters

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

member_count=1

while [ $# -gt 0 ]
do
    name="${1/--/}"
    name="${name/-/_}"
    case "--$name"  in
        --network_url) network_url="$2"; shift;;
        --proposal_file) proposal_file="$2"; shift;;
        --certificate_dir) certificate_dir="$2"; shift;;
        --member_count) member_count=$2; shift;;
        --help) usage; exit 0; shift;;
        --) shift;;
    esac
    shift;
done

# echo $network_url
# echo $certificate_dir
# echo $proposal_file

# validate parameters
if [[ -z $network_url ]]; then
    failed "Missing parameter --network-url"
elif [[ -z $certificate_dir ]]; then
   failed "You must supply --certificate-dir"
elif [[ -z $proposal_file ]]; then
    failed "Missing parameter --proposal-file"
fi

app_dir=$PWD  # application folder for reference
service_cert="$certificate_dir/service_cert.pem"
signing_cert="$certificate_dir/member0_cert.pem"
signing_key="$certificate_dir/member0_privk.pem"

# cat $proposal_file

proposal0=$( (ccf_cose_sign1 --content $proposal_file --signing-cert $signing_cert --signing-key $signing_key --ccf-gov-msg-type proposal --ccf-gov-msg-created_at $(date -Is)  | curl $network_url/gov/proposals -s -k -H "Content-Type: application/cose" --data-binary @- --cacert $service_cert -w '\n') ) 
echo $proposal0
proposal0_id=$(echo $proposal0 | jq -r '.proposal_id')
# Check if proposal0_id is null or empty
if [ -z "$proposal0_id" ]; then
    echo "Error: proposal0_id is null or empty"
    exit 1
fi

echo $proposal0_id > key_release_policy_proposal.proposal_id
