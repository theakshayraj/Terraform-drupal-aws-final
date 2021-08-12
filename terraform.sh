#! /bin/bash

echo $1
if [ $1 = 'fix' ] ; then
	packer fix packer.json
elif [ $1 = 'validate' ] ; then
	packer validate packer.json
elif [ $1 = 'build' ] ; then
	packer build packer.json
elif [ $1 = 'init' ] ; then
	terraform init
elif [ $1 = 'plan' ] ; then
	terraform plan
elif [ $1 = 'apply' ] ; then
	terraform apply
elif [ $1 = 'destroy' ] ; then
	terraform destroy
else
	echo "Unknown Options. Valid options fix|validate|build|init|plan|apply|destroy"
fi
