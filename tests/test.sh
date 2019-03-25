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
../scripts/rancher-deploy.sh patch -u https://test.fi/ra patch.json
retval=$?
if [ $retval -ne 1 ] ; then
  echo "OK: test 1"
else
  echo "FAILED: test1 $?"
fi