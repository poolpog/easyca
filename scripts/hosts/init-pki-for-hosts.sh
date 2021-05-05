#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Initialize PKI dir prior to building CA
################################################################################
set -o xtrace
set -o errexit
set -o nounset

function usage() {
    set +x
    echo
    echo "USAGE: $0 <host_label>"
    echo
    exit 1
}

CWD="${0%/*}"
#shellcheck disable=SC1090
source "${CWD}/common.inc"

if [[ -d "${PKI_DIR}"  ]]; then
    set +x
    echo "ERROR: pki dir [${PKI_DIR}] already exits; manually remove it if you really wanted to nuke this host"
    usage
fi

# PKI_DIR is set in common.inc
${EASYRSA} --batch --pki-dir="${PKI_DIR}" init-pki

cp "${EASYRSA_ROOT}/openssl-easyrsa.cnf" "${PKI_DIR}"
