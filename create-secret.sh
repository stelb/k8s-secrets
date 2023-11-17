#!/bin/bash

# quick script, nothing fancy yet

if [ "$AGEPUB" == "" ]; then
	echo AGEPUB not set
	exit 1
fi

if [ $# -lt 4 ]; then
	echo Usage: "$0 <clusterdir> <namespace> <secretname> <key1> ..."
	exit 1
fi

cluster=$1
namespace=$2
secret=$3
shift; shift; shift;

for k in $*; do
	read -p $k= v
	args="$args --from-literal=$k=$v"
done

kubectl -n $namespace create secret generic $secret \
	$args --dry-run=client -o yaml >$cluster/$namespace-$secret.yaml

sops --age=$AGEPUB \
--encrypt --encrypted-regex '^(data|stringData)$' --in-place $cluster/$namespace-$secret.yaml
