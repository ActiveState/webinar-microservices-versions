#!/usr/bin/env bash

app_base_url=`stackato apps | grep greeting | grep RUNNING | tail -1 | perl -ne 'm|(http://greeting-v1\.\S+)| && print $1'`
while [ 1 ]; do
  #echo $app_base_url
  if [ "$app_base_url" != "" ]; then
    echo `date +'%H:%M:%S'` : `curl $app_base_url/v1/greeting --silent`
  fi
  sleep 0.1
done

