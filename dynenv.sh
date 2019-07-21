#!/usr/bin/env bash -euo pipefail

echo -e '\033[0;32mLoading dynamic address information from BOSH ...
command output below ...\033[2;32m'

instances="$(bosh is | tee /dev/tty | grep running)"
first_vault="$(<<< "$instances" grep vault | head -n1 | cut -f 4)"
first_nomad="$(<<< "$instances" grep server | head -n1 | cut -f 4)"

export VAULT_ADDR="https://$first_vault:443"
export NOMAD_ADDR="http://$first_nomad:4646"

echo -e "\033[0mVAULT_ADDR=${VAULT_ADDR} NOMAD_ADDR=${NOMAD_ADDR}"
