#!/usr/bin/env bash

frontend_hostname=`stackato apps | grep frontend | grep RUNNING | tail -1 | perl -ne 'm|(http://frontend-v1.\S+)| && print $1'`
echo $frontend_hostname
while [ 1 ]; do
  if [ "$frontend_hostname" != "" ]; then
    echo `date +'%H:%M:%S'` : `curl $frontend_hostname --silent`
  fi
  sleep 1
done

