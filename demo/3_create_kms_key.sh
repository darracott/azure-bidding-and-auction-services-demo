# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi

CERTS_DIR=$KMS_DIR/workspace/sandbox_common

service_cert="$CERTS_DIR/service_cert.pem"
signing_cert="$CERTS_DIR/member0_cert.pem"
signing_key="$CERTS_DIR/member0_privk.pem"

# Add a key to the KMS
echo "Adding Key to KMS..."

# Generate a new key item
curl https://127.0.0.1:8000/app/refresh -X POST --cacert $service_cert --cert $signing_cert --key $signing_key -H "Content-Type: application/json" -i  -w '\n'
