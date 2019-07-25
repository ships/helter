#!/bin/bash -euxo pipefail

repo_root="$(cd $(dirname $0)/../.. && pwd)"

check_backend() {
  safe vault secrets list -detailed | grep 'kvv1.*version:1'
}

enable_backend() {
  safe vault secrets enable \
     -path kvv1 \
     -version 1 \
     kv
}

idem_enable_backend() {
  check_backend || enable_backend
}

write_authorities() {
  safe vault policy write nomad-server "${repo_root}/final/nomad-server-policy.hcl"
  safe vault write /auth/token/roles/nomad-cluster "@${repo_root}/final/nomad-cluster-token-role.json"
}

issue_initial_token() {
  cat <<DOCUMENT > "${repo_root}/tmp/secrets/nomad-vault-token.yml"
nomad_vault_boot_token: "$(safe vault token create -policy nomad-server -period 72h -orphan | grep '^token\s' | awk '{print $2;}')"
DOCUMENT
}

idem_enable_backend
write_authorities
issue_initial_token
