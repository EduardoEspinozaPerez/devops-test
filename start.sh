#!/bin/sh

# Azure credentials
export TF_VAR_arm_subscription_id=
export TF_VAR_arm_client_id=
export TF_VAR_arm_client_secret=
export TF_VAR_arm_tenant_id=

# VMs SSH public key
export TF_VAR_ssh_public_key=

echo '-----------------------DevOps Test------------------------'
echo 'Author: Eduardo Espinoza Perez <eduardo.espinoza@tenpo.cl>'
echo '----------------------------------------------------------'

echo '[PostgreSQL image configuration] Starting'
packer build -force packer-postgresql.json
echo '[PostgreSQL image configuration] Finished'

echo '[Docker + TestAPI image configuration] Starting'
packer build -force packer-docker.json
echo '[Docker + TestAPI image configuration] Finished'

echo '[Infrastructure creation] Starting'
terraform init
terraform plan
terraform apply -auto-approve
echo '[Infrastructure creation] Finished'