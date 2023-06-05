#!/bin/bash
set -x
source env.sh

terraform_variables=(\
-var "region=${REGION}" \
-var "profile=${PROFILE}" \
)

terraform init -reconfigure
terraform plan ${terraform_variables[*]}