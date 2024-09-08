#!/bin/sh
cp base.yaml pivot.yaml
cat >> pivot.yaml
# you can also use "kustomize build ." if you have it installed.
exec kubectl kustomize| envsubst 
rm pivot.yaml
