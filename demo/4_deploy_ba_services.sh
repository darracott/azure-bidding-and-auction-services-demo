# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$KMS_DIR" ]; then
    BA_DIR=~/demo/bidding-auction-servers
fi
REPO_PATH=$(realpath $(dirname "$0")/..)

# Run the B&A servers
declare -A service_pid
(
    cd $BA_DIR
    source $REPO_PATH/scripts/env
    ./bazel-bin/services/bidding_service/server --init_config_client="true" &
    service_pid["bidding"]=$!
    ./bazel-bin/services/buyer_frontend_service/server --init_config_client="true" &
    service_pid["bfe"]=$!
    ./bazel-bin/services/auction_service/server --init_config_client="true" &
    service_pid["auction"]=$!
    ./bazel-bin/services/seller_frontend_service/server --init_config_client="true" &
    service_pid["sfe"]=$!
)

# Wait until the user presses Ctrl+C
cleanup() {
    pkill -f "python /opt/ccf_virtual/bin/start_network.py" > /dev/null 2>&1
    pkill -f "./bazel-bin/services" > /dev/null 2>&1
    exit 0
}
echo "B&A services are running, press Ctrl+C to stop..."
trap cleanup SIGINT
while true; do
    sleep 1
done