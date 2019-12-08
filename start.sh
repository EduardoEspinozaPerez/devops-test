#!/bin/sh

export TF_VAR_arm_subscription_id=
export TF_VAR_arm_client_id=
export TF_VAR_arm_client_secret=
export TF_VAR_arm_tenant_id=

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