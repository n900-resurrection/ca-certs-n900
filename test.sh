TEST_NAME=ca-certs-n900
need_pkg ca-certs-n900
ok ids-list test -s /opt/ca-certs-n900/ids
contains status-all "certificates installed" ca-certs-n900 status
contains isrg-root "ISRG Root X1" su user -c 'cmcli -t ssl-ca -L'
ok isrg-not-in-system sh -c '! cmcli -T common-ca -L | grep -q "ISRG Root X1"'
t usage-exit 2 sh -c 'ca-certs-n900 bogus >/dev/null 2>&1; echo $?'
summary
