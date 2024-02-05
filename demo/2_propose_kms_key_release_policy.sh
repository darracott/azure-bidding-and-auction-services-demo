
# Add key release policy
# source .venv_ccf_sandbox/bin/activate

if [ -z "$KMS_DIR" ]; then
    KMS_DIR=~/demo/azure-privacy-sandbox-kms
fi

./helpers/submit_proposal.sh --network-url https://127.0.0.1:8000 --proposal-file $KMS_DIR/governance/policies/key-release-policy-add.json --certificate_dir ~/demo/azure-privacy-sandbox-kms/workspace/sandbox_common 