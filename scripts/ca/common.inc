#!/usr/bin/env bash
# This is the CA common.inc 

CWD="${0%/*}"
#shellcheck disable=SC1090
source "${CWD}/../common.inc"

# CA-only configs
export PKI_DIR="${INTERNAL_CAS_DATA}/ca/pki"
