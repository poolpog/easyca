#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Creates a Java keystore from the specified, issued, ssl cert, for
#               the purpose of handling trusted CA certs, local self-signed certs,
#               etc., for use by internally-developed Java programs.
#
#               This is a 1:1 map of cert:keystore -- i.e. only one signed cert
#               can be imported into a keystore.
#
#               This script requires:
#                   * Run Manually, one time per JKS file (i.e. once per self-signed cert)
#                   * Can be run again to rebuild the JKS, though
#                   * Run it on the Cert Authority server. That's the puppetserver
#                   * Run after the PKI infrastructure is built using the EasyRSA-based
#                     scripts
################################################################################
set -o xtrace
set -o errexit
set -o nounset

function usage() {
    set +x
    echo
    echo "USAGE: $0 <CERT_NAME> <PASSWORD>"
    echo "  <CERT_NAME>  Name of the certificate or 'host' as found in the hosts/ subdir of internal-cas-data/"
    echo "  <PASSWORD>   New password that will encrypt the keystore and be saved in a CERT_NAME.pass file"
    echo
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

function set_permissions() {
    THE_FILE="${1}"
    if [[ -f "${THE_FILE}" ]]; then
        chown root:optsec "${THE_FILE}"
        chmod 640 "${THE_FILE}"
    fi
}

CWD="${0%/*}"
#shellcheck disable=SC1090
source "${CWD}/common.inc"

CERT_NAME="${1}"
PASSWORD="${2}"


# # STEPS
# 1) Create password file and save in "example.key.pass" IN: /opt/secrets/internal-cas-data/
# 2) Import PK into example.jks file (Might already be done)
# 3) Import all the other CA certs and whatnot into this JKS file (Might already be done)
# 4) **password-protect** the JKS file using the password from (1)
# 5) Capture this in documentation or a script or something

# This dir is configured as part of modules/internal_cas; import all the trusted certs in this path
# Should only include CA certs that aren't part of the internal ca infrastructure (e.g. RDS certs)
TRUSTED_CERTS_PATH="/opt/internal-cas/trusted-certs"

# Because of the way the EasyRSA-based cert management system works, all certs, csrs, keys, etc., will
# live in a consistently organized directory hiearchy
DATA_DIR="/opt/secrets/internal-cas-data"
WORK_DIR="${DATA_DIR}/work"
KEYSTORES_DIR="${DATA_DIR}/java-keystores"
PASSWORDS_DIR="${DATA_DIR}/password-files"

CA_PKI_DIR="${DATA_DIR}/ca/pki"
CA_ISSUED_DIR="${CA_PKI_DIR}/issued"
CA_NAME="INTERNAL_CA"

HOSTS_DIR="${DATA_DIR}/hosts"
HOSTS_PKI_DIR="${HOSTS_DIR}/${CERT_NAME}/pki"
PATH_TO_CERT_KEY="${HOSTS_PKI_DIR}/private/${CERT_NAME}.key"

PATH_TO_PASSWORD_FILE="${PASSWORDS_DIR}/${CERT_NAME}.pass"
PATH_TO_CERT="${CA_ISSUED_DIR}/${CERT_NAME}.crt"
PATH_TO_CERT_P12="${KEYSTORES_DIR}/${CERT_NAME}.p12"
PATH_TO_JKS_FILE="${KEYSTORES_DIR}/${CERT_NAME}.jks"


TRUSTED_CERTS_DIR="/opt/internal-cas/trusted-certs"

TEMP_DIR=$( mktemp -d "${WORK_DIR}/tempdir.XXXXXXXX" )
cd "${TEMP_DIR}"

set +e
# Running these files through openssl ensures they output a valid cert
find "${TRUSTED_CERTS_PATH}" -type f | sort | xargs -n1 -P1 openssl x509 -in > "${TEMP_DIR}/all.pem"
set -e

NOW=$( date "+%Y-%m-%d-%H-%M-%S" )

# 1. Create password file
touch "${PATH_TO_PASSWORD_FILE}"
set_permissions "${PATH_TO_PASSWORD_FILE}"
echo -n "${PASSWORD}" > "${PATH_TO_PASSWORD_FILE}"

# 2. Convert cert to pkcs12 format and output to CERTNAME.p12
openssl pkcs12 -export \
    -in "${PATH_TO_CERT}" \
    -inkey "${PATH_TO_CERT_KEY}" \
    -certfile "${PATH_TO_CERT}" \
    -out "${PATH_TO_CERT_P12}.${NOW}" \
    -password "file:${PATH_TO_PASSWORD_FILE}"

# 2. Create initial java keystore as CERTNAME.jks
# ==============================================================================
# Creates a JKS protected with the private key's password. The certificates
# private key is imported, without a password, into the JKS.
keytool -importkeystore \
    -srckeystore "${PATH_TO_CERT_P12}.${NOW}" \
    -srcstoretype pkcs12 \
    -srcstorepass "${PASSWORD}" \
    -srcalias "1" \
    -destkeystore "${PATH_TO_JKS_FILE}.${NOW}" \
    -deststoretype JKS \
    -deststorepass "${PASSWORD}" \
    -destalias "${CERT_NAME}"


# 3. Import internal environment CA
keytool -keystore "${PATH_TO_JKS_FILE}.${NOW}" -alias "${CA_NAME}" -import -file "${CA_PKI_DIR}/ca.crt" -noprompt -storepass "${PASSWORD}"

# 4. Import all external CAs
for CERT in $(find "${TRUSTED_CERTS_DIR}" -type f -print0 | xargs -0 ); do
# Running these files through openssl ensures they output a valid cert
    if openssl x509 -in "${CERT}" >/dev/null 2>&1 ; then
        CERT_ALIAS="$(basename "${CERT}")"
        keytool -keystore "${PATH_TO_JKS_FILE}.${NOW}" -alias "${CERT_ALIAS}" -import -file "${CERT}" -noprompt -storepass "${PASSWORD}"
    else
        echo "ERROR: Cert [${CERT}] malformed; cert not imported"
    fi
done

# 5. Symlinks
set_permissions "${PATH_TO_CERT_P12}.${NOW}"
set_permissions "${PATH_TO_JKS_FILE}.${NOW}"
ln -f -n -s "${PATH_TO_JKS_FILE}.${NOW}" "${PATH_TO_JKS_FILE}"
