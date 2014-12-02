#!/usr/bin/env bash

set -x

basedir=`dirname $0`
rootdir=`cd $basedir/../.. && pwd`

source $rootdir/util/deployment-functions.sh

deploy immutable greeting v1
deploy immutable name v1
deploy immutable name v2

