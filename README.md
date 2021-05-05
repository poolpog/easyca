# EASYCA: PKI Management for Internal Certs

## Description
This module provides tooling to manage an internal self-signing CA.
This module only creates and signs certs. It does not install or otherwise manage them.
I wrote this initially for a work project so some of the idioms used were tailored to that environment. I tried to make this as generic as possible,
but there are some key things missing, such as:

* Needs better configuration tooling
* Should accept CLI args
* Some values should be required to be set before use and not have defaults

## Definitions
* "PKI" -> Public Key Infrastructure
* "CA" -> Certificate Authority; the cert that is used to issue (i.e. sign) signed certs
* "CSR" -> Certificate Signing Request
* "host" -> a host or service or CN that needs a certificate. e.g. "*.example.com" or "vpn-server"

## Process

Here is how to create and manage a CA, with an example CA and example CA-signed cert.
This example cert is the wildcard certificate for "*.example.com"

The outcome of this example is:

* An organized CA directory structure to house certs, keys, and related artifacts for the CA
* An organized service/host directory structure to house keys, CSRs, and related artifacts for hosts requesting signed certs
* A CA certficate and private key
* A CA-signed wildcard certificate usable for internal SSL communications

0. Instsall EasyRSA

    /opt/internal-cas/scripts/ca/install-easyrsa.sh

1. Initialize PKI dir for the CA

    /opt/internal-cas/scripts/ca/init-pki.sh
 
2.  Create the CA cert and key

    /opt/internal-cas/scripts/ca/build-ca.sh example-ca

3. Init PKI for a "host"

    /opt/internal-cas/scripts/hosts/init-pki-for-hosts.sh star_example_com
 
4.  Create CSR for host

    /opt/internal-cas/scripts/hosts/gen-req-for-host.sh star_example_com "*.example.com"

5.  Sign CSR for Host and issue cert. the CA performs signing tasks, so the script is in the "ca" script dir

    /opt/internal-cas/scripts/ca/sign-req-for-host.sh star_example_com
