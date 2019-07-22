#!/bin/bash -euxo pipefail

repo_root="$(cd $(dirname $0)/../.. && pwd)"

safe vault policy write nomad-server "${repo_root}/final/nomad-server-policy.hcl"
safe vault write /auth/token/roles/nomad-cluster "@${repo_root}/final/nomad-cluster-token-role.json"
cat <<DOCUMENT > "${repo_root}/tmp/secrets/nomad-vault-token.yml"
nomad_vault_boot_token: "$(safe vault token create -policy nomad-server -period 72h -orphan | grep '^token\s' | awk '{print $2;}')"
DOCUMENT
