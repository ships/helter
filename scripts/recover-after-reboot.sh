#!/bin/bash

bosh -nd raft recreate --fix
bosh -nd safe recreate --fix
bosh -nd work recreate --fix
bosh -nd db recreate --fix

source ./dynenv.sh

./scripts/show-unseal-keys.sh | xargs -n1 -I{} safe vault operator unseal {}
