#!/bin/bash -euxo pipefail

repo_root="$(cd $(dirname $0)/../.. && pwd)"

pushd "${repo_root}"

  bosh deploy     src/deployments/raft.yml \
                  -d raft \
                  -l tmp/secrets/nomad-vault-token.yml \
                  -n

popd
