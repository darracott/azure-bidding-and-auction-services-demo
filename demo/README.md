
If you haven't already then initialise the demo repo by running:
- `./scripts/setup.sh`
- `./scripts/build.sh`
- `pip install ccf`

## Deploy the KMS
First, open three terminal windows and run `cd demo`. Two of the terminals are for operator actions, running the KMS, and running the BA services, and the third is to perform coordinator/member actions.  

In the first terminal deploy the KMS by running:
  ```
  ./1_deploy_kms.sh
  ```
This deploys CCF running the KMS application with three initial members.

## Propose a new member (Optional)
An existing member of the KMS can make a proposal to add a new member.
```
./helpers/create_and_propose_member.sh <NEW_MEMBER_NAME>
```
After a proposal has been made, existing members can vote on whether to accept or reject the proposal. 

To see the open proposals on which a member can vote, run:
```
./poll.sh $(cat <MEMBER_NAME>.id)
```

The following commands show members voting on a proposal
```
./helpers/vote.sh accept member0 <PROPOSAL_ID>  # member0 votes to accept the proposal
./helpers/vote.sh reject member1 <PROPOSAL_ID>  # member1 votes to reject the proposal
./helpers/vote.sh accept member2 <PROPOSAL_ID>  # member2 votes to accept the proposal
```
## Activate a new member (Optional)
New KMS members need to activate their role once they have been accepted. This essentially involves requesting the state of the KMS. Then assessing the state and signing and returning it if it was deemed acceptable. The new member is then partially responsible, along with all other members, for the ongoing state of the KMS.
```
./helpers/activate_member.sh <NEW_MEMBER_NAME>
```

## Update the Key Release Policy
The KMS securely stores important keys. The KMS is configured with a policy (the Key Release Policy) which specifies who/what can access the keys it stores. 

Members can propose updates to the key release policy: 
```
./2_propose_kms_key_release_policy.sh
```

Members vote on this proposal:
```
./helpers/vote.sh accept member2 $PROPOSAL_ID  # member2 votes to accept the proposal
./helpers/vote.sh accept member0 $PROPOSAL_ID  # member0 votes to accept the proposal
./helpers/vote.sh accept member1 $PROPOSAL_ID  # member1 votes to accept the proposal
```

### Create a key in the KMS
Operators can securely create keys within the KMS.
```
./3_create_kms_key.sh
```

## Start BA services 
To function properly BA services must meet the KMS's Key Release Policy and request a key from the KMS.
```
./4_deploy_ba_services.sh
```

## Test the BA Services
Send an example request:
```
TARGET_SERVICE=bfe REQUEST_PATH=requests/get_bids_request.json ../scripts/request.sh
```


## Notes
Lifecycle events:
- Adding new members
- Members voting on proposals (polling for proposal IDs)
- Removing a member
- Updating the Key Release Policy
- Updating BA service(s) and updating Key Release Policy accordingly.
- Updating the KMS
    - Updating the version of CCF on which KMS is running.  
    - Updating the KMS code without changing the CCF version. (Externally both of these look like a KMS update but interally they might look slighly different)

