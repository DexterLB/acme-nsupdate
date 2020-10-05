#!/bin/bash

set -e

script_dir="$(dirname "$(readlink -f "${0}")")"
cd "${script_dir}"

. ./config.sh

challenge_domain="_acme-challenge.$CERTBOT_DOMAIN"

if [[ "$0" =~ auth_hook\.sh$ ]]; then
    action="
        server ${dns_server}
        update add ${challenge_domain} 60 TXT ${CERTBOT_VALIDATION}
        send
    "

elif [[ "$0" =~ cleanup_hook\.sh$ ]]; then
    action="
        server ${dns_server}
        update delete ${challenge_domain} TXT
        send
    "
else
    echo "unknown script: ${0}" >&2
    exit 1
fi

echo "${action}" | nsupdate -k "${key_file}"

sleep 2
