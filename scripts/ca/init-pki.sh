#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Initialize PKI dir prior to building CA
################################################################################
set -o xtrace
set -o errexit
set -o nounset

CWD="${0%/*}"
#shellcheck disable=SC1090
source "${CWD}/common.inc"

function usage() {
    set +x
    echo
    echo "USAGE: $0"
    echo
    exit 1
}

if [[ -d "${PKI_DIR}"  ]]; then
    set +x
    echo "ERROR: pki dir [${PKI_DIR}] already exits; manually remove it if you really wanted to nuke this CA"
    usage
fi

"${EASYRSA}" --batch --pki-dir="${PKI_DIR}" init-pki

cp "${EASYRSA_ROOT}/openssl-easyrsa.cnf" "${PKI_DIR}"
