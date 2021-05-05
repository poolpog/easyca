#!/usr/bin/env bash
# This is the top-level common.inc 

# Pattern is
# 1. init-pki
# 2. create vars file in CAS_DATA directory
# 3. build-ca
# 4. issue and sign certs
#   a. create csr and key -- gen-req
#   b. sign csr -- sign-req
#   c. generate dh params -- gen-dh
#   d. generate client cert and key -- build-client-full

export INTERNAL_CAS_ROOT="/opt/internal-cas"
export INTERNAL_CAS_DATA="${INTERNAL_CAS_ROOT}/internal-cas-data"
export EASYRSA_WORK="/opt/easy-rsa-versions"
export EASYRSA_ROOT="/opt/easy-rsa"
export EASYRSA="${EASYRSA_ROOT}/easyrsa"

for DIR in ${INTERNAL_CAS_ROOT} ${INTERNAL_CAS_DATA} ${EASYRSA_WORK} ${EASYRSA_ROOT}; do
    if [[ ! -d "${DIR}" ]]; then
        mkdir "${DIR}"
    fi
done
