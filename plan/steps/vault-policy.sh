#!/bin/bash -euxo pipefail

repo_root="$(cd $(dirname $0)/../.. && pwd)"

check_backend_kvv1() {
  safe vault secrets list -detailed | grep '^kvv1.*version:1'
}

enable_backend_kvv1() {
  safe vault secrets enable \
     -path kvv1 \
     -version 1 \
     kv
}

enable_backend_pki() {
  safe vault secrets enable pki

  safe vault write pki/roles/skelter-services \
    allowed_domains=service.skelter \
    allow_subdomains=true \
    max_ttl=72h \
    generate_lease=true \
    require_cn=false

  safe vault write pki/config/urls \
    issuing_certificates="http://vault.service.skelter:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.service.skelter:8200/v1/pki/crl"

  safe vault write pki/root/generate/internal common_name='root CA for nomad-deployed services' ttl=87600h
}

check_backend_pki() {
  safe vault secrets list -detailed | grep '^pki/'
}

idem_enable_backends() {
  check_backend_kvv1 || enable_backend_kvv1
  check_backend_pki || enable_backend_pki
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

idem_enable_backends
write_authorities
issue_initial_token
