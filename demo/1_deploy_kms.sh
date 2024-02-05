# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

# Check port 8000 is free
if lsof -i :8000 > /dev/null 2>&1; then
    echo "Port 8000 is not free, please stop any process using it and try again"
    exit 1
fi

# Start KMS
(
    cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    env -i PATH=$PATH /opt/ccf_virtual/bin/sandbox.sh --js-app-bundle ./dist/ --initial-member-count 3 --initial-user-count 1 --constitution ./governance/constitution/kms_actions.js -v --http2 &
)

# Wait for the KMS to start
response_code=000
while ! [[ $response_code -eq 400 ]]; do
    sleep 1
    response_code=$(curl https://127.0.0.1:8000/app/listpubkeys -k -s -o /dev/null -w "%{http_code}")
done
sleep 1 # Allow CCF to finish spinning up

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi
CERTS_DIR=$KMS_DIR/workspace/sandbox_common

# Write member IDs to file for easy use later.
openssl x509 -in $CERTS_DIR/member0_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member0.id
openssl x509 -in $CERTS_DIR/member1_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member1.id
openssl x509 -in $CERTS_DIR/member2_cert.pem -noout -fingerprint -sha256 | cut -d "=" -f 2 | sed 's/://g' | awk '{print tolower($0)}' > member2.id


# Wait until the user presses Ctrl+C
cleanup() {
    pkill -f "python /opt/ccf_virtual/bin/start_network.py" > /dev/null 2>&1
    pkill -f "./bazel-bin/services" > /dev/null 2>&1
    exit 0
}
echo "KMS is running, press Ctrl+C to stop..."
trap cleanup SIGINT
while true; do
    sleep 1
done