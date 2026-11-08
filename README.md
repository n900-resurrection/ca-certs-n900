# ca-certs-n900

Current Mozilla root certificates for MicroB and other programs of the Nokia N900 (Maemo 5).

The phone has only root certificates from 2010 in the read-only system domain `common-ca` and lacks about 117 current ones
(ISRG Root X1 of Let's Encrypt, DigiCert G2/G3, GlobalSign R3, USERTrust and others). This package adds the Mozilla list
(118 certificates, taken from the curl build of the N900 project) to the **private** certificate domain `ssl-ca` of the user
(`~/.maemosec-certs/ssl-ca`, managed by `cmcli` of the Maemo certificate manager). MicroB reads this domain; the system
domain is not changed.

```
ca-certs-n900 status [user]     # how many of the certificates are installed
ca-certs-n900 install [user]    # add them (done by the package when it is installed)
ca-certs-n900 remove [user]     # remove exactly the certificates of this package (done before the package is removed)
```

## Limits
MicroB (Gecko 1.9.2, NSS 3.12.6) speaks only TLS 1.0, so sites that disabled TLS 1.0 and 1.1 still fail (a Google, Facebook or Seznam page
gives a protocol error). The certificates help only for sites that still accept TLS 1.0 but use a chain to a newer root.

## Verification
The mechanism was verified with a temporary test CA and `openssl s_server -tls1` on a PC: `cmcli -v` fails without the CA, gives
"Verified OK" with it, and MicroB opens the page without a warning.

Build (in the N900 project): `make debs APP=ca-certs-n900`, tests on the phone: `make -C apps/ca-certs-n900 test`.
