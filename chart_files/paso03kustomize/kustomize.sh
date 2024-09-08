#!/bin/sh
cat > base.yaml
exec kubectl kustomize| envsubst
rm base.yaml
