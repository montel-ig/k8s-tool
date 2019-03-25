#!/bin/bash

echo "Test: No Params"
../scripts/rancher-deploy.sh
retval=$?
if [ $retval -eq 1 ] ; then
  echo "OK: no Params OK"
else
  echo "FAILED: no Params: $?"
fi

echo "Test: test 1"
../scripts/rancher-deploy.sh patch -s https://test.fi/ra -t dd -d test -n vantool-pro  -r https://gitlab.com/montel-ig/vantool patch.json --dry-run
retval=$?
if [ $retval -ne 1 ] ; then
  echo "OK: test 1"
else
  echo "FAILED: test1 $?"
fi