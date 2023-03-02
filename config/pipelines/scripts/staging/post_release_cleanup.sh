#!/usr/bin/env bash

set -e

echo "keep release number: $1"

echo "cleaning up buckets"

KEEP_RELEASE_NR="NR>$1";

bucketCount=`find . -type f | wc -l`

if [ "$bucketCount" -gt "$1" ];
then
    echo "cleaning up buckets"
    rm `ls -t | awk $KEEP_RELEASE_NR`
else
    echo "no cleanup required"
fi