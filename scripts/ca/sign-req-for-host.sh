#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Sign CSR
#
#               This will sign a CSR and issue a certificate. Signed cert gets
#               placed in /opt/secrets/internal-cas-data/ca/pki/issued/
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
    echo "USAGE: $0 <host_label> [<cert_type>]"
    echo
    echo "    <cert_type> (optional)    server,client"
    echo
    exit 1
}

HOST_LABEL="${1:-FALSE}"
CERT_TYPE="${2:-server}"
REQ_DIR="${PKI_DIR}/../../hosts/${HOST_LABEL}/pki/reqs/"
REQ="${REQ_DIR}/${HOST_LABEL}.req"

if [[ "${HOST_LABEL}" == "FALSE" ]]; then
    usage
fi
if [[ ! -f  "${REQ}" ]]; then
    set +x
    echo
    echo "ERROR: CSR file [${REQ}] does not exist. Initialize host [${HOST_LABEL}] first"
    usage
fi

if ! "${EASYRSA}" --batch --pki-dir="${PKI_DIR}" show-req "${HOST_LABEL}"; then
    ${EASYRSA} --batch --pki-dir="${PKI_DIR}" import-req "${REQ}" "${HOST_LABEL}"
fi

${EASYRSA} --batch --pki-dir="${PKI_DIR}" sign-req "${CERT_TYPE}" "${HOST_LABEL}"
