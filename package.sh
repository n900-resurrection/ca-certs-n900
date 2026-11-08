#!/bin/bash
# Package ca-certs-n900 as a .deb for Maemo 5: the Mozilla CA list (from the curl build) split into PEM files named by the SHA-1 key id
# that the Maemo certificate manager (cmcli) uses. make -C apps/ca-certs-n900 deb   (needs build/out/curl-*/cacert.pem: make -C apps/curl)
set -euo pipefail
PROJ=/project
. "$PROJ/scripts/debpack.sh"

PKG=ca-certs-n900
VERSION="${VERSION:-1.0}"
STAGE="$PROJ/build/deb/stage-$PKG"
HERE="$PROJ/apps/ca-certs-n900"
CA=$(ls "$PROJ"/build/out/curl-*/cacert.pem | tail -1)

rm -rf "$STAGE"
mkdir -p "$STAGE/opt/ca-certs-n900/certs" "$STAGE/usr/bin" "$STAGE/DEBIAN"
python3 -I - "$CA" "$STAGE/opt/ca-certs-n900" <<'PY'
import sys, re, base64, hashlib
txt = open(sys.argv[1]).read(); out = sys.argv[2]
ids = []
for b in re.findall(r'-----BEGIN CERTIFICATE-----\n(.*?)-----END CERTIFICATE-----', txt, re.S):
    der = base64.b64decode(b)
    i = hashlib.sha1(der).hexdigest()
    ids.append(i)
    open('%s/certs/%s.pem' % (out, i), 'w').write('-----BEGIN CERTIFICATE-----\n%s-----END CERTIFICATE-----\n' % b)
open(out + '/ids', 'w').write('\n'.join(sorted(ids)) + '\n')
print(len(ids), 'certificates')
PY
chmod -R u=rwX,go=rX "$STAGE/opt/ca-certs-n900"
install -m 755 "$HERE/ca-certs-n900" "$STAGE/usr/bin/ca-certs-n900"
cat > "$STAGE/DEBIAN/postinst" <<'EOT'
#!/bin/sh
[ "$1" = configure ] && id user >/dev/null 2>&1 && /usr/bin/ca-certs-n900 install user
exit 0
EOT
cat > "$STAGE/DEBIAN/postrm" <<'EOT'
#!/bin/sh
exit 0
EOT
cat > "$STAGE/DEBIAN/prerm" <<'EOT'
#!/bin/sh
case "$1" in remove|purge) id user >/dev/null 2>&1 && /usr/bin/ca-certs-n900 remove user ;; esac
exit 0
EOT
chmod 755 "$STAGE/DEBIAN/postinst" "$STAGE/DEBIAN/postrm" "$STAGE/DEBIAN/prerm"

SECTION=user/system
DEPENDS="maemosec-certman-tools"
DISPLAY_NAME="ca-certs-n900"
SHORT_DESC="Current Mozilla root certificates for MicroB and other Maemo programs"
LONG_DESC="The phone has root certificates from 2010 and lacks about 117 current ones (ISRG Root X1, DigiCert G2/G3, GlobalSign R3, USERTrust and others).
The package adds the missing ones to the private certificate domain ssl-ca of the user (the Maemo certificate manager, read by MicroB); the system domain common-ca is not changed. Removing the package removes exactly these certificates.
Note: MicroB speaks only TLS 1.0, so sites that disabled it still fail. Tool: ca-certs-n900 install|remove|status."
debpack_build
