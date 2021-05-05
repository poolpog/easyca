#!/usr/bin/env bash
################################################################################
#  DESCRIPTION: Download and install easyrsa from OpenVPN's Github
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
    echo "USAGE: $0 <version>"
    echo "  <version>      Version, e.g. 3.0.6"
    echo
    exit 1
}

VERSION="${1:-3.0.6}"

TEMPDIR=$( mktemp -d "${EASYRSA_WORK}/download.XXXXXX" )
LOCKFILE="${EASYRSA_WORK}/.easyrsa-installed"
DOWNLOAD_URL="https://github.com/OpenVPN/easy-rsa/releases/download/v${VERSION}/EasyRSA-unix-v${VERSION}.tgz"

# 0. Exit if version is already installed...
if [[ -f "${LOCKFILE}" ]]; then
    if grep -q "${VERSION}" "${LOCKFILE}" ; then
        echo "ERROR: Version [v${VERSION}] is already installed"
        usage
    fi
fi

# ...Proceed otherwise

if [[ -f /opt/scripts/includes/proxy.sh ]]; then
    source /opt/scripts/includes/proxy.sh
fi

# 1. Download
curl -L -o "${TEMPDIR}/EasyRSA-unix-v${VERSION}.tgz" "${DOWNLOAD_URL}"
rm -rf "${EASYRSA_WORK}/EasyRSA-v${VERSION}/"
rm -rf "${EASYRSA_ROOT}"

# 2. Unpack
tar zxf "${TEMPDIR}/EasyRSA-unix-v${VERSION}.tgz" -C "${EASYRSA_WORK}"
chown -R root:root "${EASYRSA_WORK}/EasyRSA-v${VERSION}/"

# 3. Symlinks
ln -n -f -s "${EASYRSA_WORK}/EasyRSA-v${VERSION}/" "${EASYRSA_ROOT}"
ln -n -f -s "${INTERNAL_CAS_ROOT}/scripts/vars" "${EASYRSA_ROOT}/vars"

# 4. Lock installation
echo "${VERSION}" > "${LOCKFILE}"

# 5. Cleanup
rm -rf "${TEMPDIR}"
