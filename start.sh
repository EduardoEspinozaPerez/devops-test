#!/bin/sh

export TF_VAR_ARM_SUBSCRIPTION_ID=
export TF_VAR_ARM_CLIENT_ID=
export TF_VAR_ARM_CLIENT_SECRET=
export TF_VAR_ARM_TENANT_ID=

echo '-----------------------DevOps Test------------------------'
echo 'Author: Eduardo Espinoza Perez <eduardo.espinoza@tenpo.cl>'
echo '----------------------------------------------------------'

echo '[PostgreSQL image configuration] Starting'
packer build packer-postgresql.json
echo '[PostgreSQL image configuration] Finished'

echo '[Docker + TestAPI image configuration] Starting'
packer build packer-docker.json
echo '[Docker + TestAPI image configuration] Finished'

echo '[Infrastructure creation] Starting'
terraform init
terraform plan
terraform apply -auto-approve
echo '[Infrastructure creation] Finished'