#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Initialize CA
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
    echo "USAGE: $0 <ca_req_cn>"
    echo
    echo "    <ca_req_cn>   CN for this CA"
    echo
    exit 1
}

CA_REQ_CN="${1:-FALSE}"

if [[ -f "${PKI_DIR}/ca.crt" ]]; then
    set +x
    echo "ERROR: CA cert for CA [${CA_REQ_CN}] already exits; manually remove PKI dir [${PKI_DIR}] if you really wanted to nuke this CA"
    usage
fi


if [[ "${CA_REQ_CN}" != "FALSE" ]]; then
    ${EASYRSA} --batch --pki-dir="${PKI_DIR}" --req-cn="${CA_REQ_CN}" build-ca nopass
    # This copies the ca cert file to an identical file named after the CA itself; just for clarity/backup
    cp "${PKI_DIR}/ca.crt" "${CA_REQ_CN}-ca.crt"
else
    usage
fi



