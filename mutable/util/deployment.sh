#!/usr/bin/env bash

set -x

basedir=`dirname $0`
rootdir=`cd $basedir/../.. && pwd`

source $rootdir/util/deployment-functions.sh

deploy mutable greeting v1
deploy mutable name v1
deploy mutable name v2

