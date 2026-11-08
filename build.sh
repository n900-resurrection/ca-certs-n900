#!/bin/bash
# Nothing to compile: package.sh splits the CA bundle of the curl build into PEM files.
ls /project/build/out/curl-*/cacert.pem >/dev/null
