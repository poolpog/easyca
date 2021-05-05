#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Generate CSR for a given cert hostname
#
#               Can include SANs for the hostname as well
################################################################################
set -o xtrace
set -o errexit
set -o nounset

function usage() {
    set +x
    echo
    echo "USAGE: $0 <host_label> <cn_on_cert> [SAN1 [SAN2] [...]]"
    echo
    exit 1
}

CWD="${0%/*}"
#shellcheck disable=SC1090
source "${CWD}/common.inc"

# HOST_CN is required for host req operations
# For wildcards, use "*." at the front -- be sure to wrap the name in quotes
HOST_CN="${1:-FALSE}"
shift
HOST_SANS="${*:-FALSE}"

if [[ "${HOST_CN}" == "FALSE" ]]; then
    usage
fi

# PKI_DIR is set in common.inc
if [[ ! -d "${PKI_DIR}" ]]; then
    ${EASYRSA} --batch --pki-dir="${PKI_DIR}" init-pki
fi

if [[ "${HOST_SANS}" != "FALSE" ]]; then
    "${EASYRSA}" --batch --subject-alt-name="DNS:${HOST_SANS// /,DNS:}" --pki-dir="${PKI_DIR}" --req-cn="${HOST_CN}" gen-req "${HOST_LABEL}" nopass
else
    "${EASYRSA}" --batch --pki-dir="${PKI_DIR}" --req-cn="${HOST_CN}" gen-req "${HOST_LABEL}" nopass
fi
