#!/usr/bin/env bash
# This is the HOSTS common.inc 

#shellcheck disable=SC1090
source "${CWD}/../common.inc"

# HOST-only configs
# HOST_LABEL is required for all "hosts/*" scripts -- it is used in the path to the host's pki dir
HOST_LABEL="${1:-FALSE}"

if [[ "${HOST_LABEL}" == "FALSE" ]]; then
    usage
fi
shift

export PKI_DIR="${INTERNAL_CAS_DATA}/hosts/${HOST_LABEL}/pki"
