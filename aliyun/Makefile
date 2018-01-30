.ONESHELL:
.PHONEY: help set-env init update plan plan-destroy show graph apply output taint

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(ENVIRONMENT) ]; then\
		 echo "ENVIRONMENT was not set"; exit 10;\
	 fi

init: set-env
	@rm -rf .terraform/*.tf*
	@terraform remote config \
		-backend=S3 \
		-backend-config="region=region" \
		-backend-config="bucket=$(ENVIRONMENT)-company-region-terraform-state" \
		-backend-config="key=ecs-cluster/$(ENVIRONMENT).tfstate"\
	  	-backend-config="encrypt=1"\
		-backend-config="kms_key_id=arn:aws:kms:region:xxxxxxxxxxxxx:key/xxxx-xxxx-xxxxx-xxxx-xxxxxxxxxxxxxxxxxxxxx"
	@terraform remote pull

update: ## Gets a newer version of the state
	@terraform get -update=true 1>/dev/null

plan: init update ## Runs a plan to show proposed changes.
	@terraform plan -input=false -refresh=true -module-depth=-1 -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars

plan-destroy: init update ## Runs a plan to show what will be destroyed
	@terraform plan -input=false -refresh=true -module-depth=-1 -destroy -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars

show: init
	@terraform show -module-depth=-1

graph: ## Creates a graph of the resources that Terraform is aware of
	@rm -f graph.png
	@terraform graph -draw-cycles -module-depth=-1 | dot -Tpng > graph.png
	@open graph.png

apply: init update ## DANGER! Runs changes against your environment
	@terraform apply -input=true -refresh=true -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars && terraform remote push

output: init update
	@if [ -z $(MODULE) ]; then\
		terraform output;\
	 else\
		terraform output -module=$(MODULE);\
	 fi

taint: init update ## Specifically choose a resource to taint
	@echo "Tainting involves specifying a module and a resource"
	@read -p "Module: " MODULE &&\
		read -p "Resource: " RESOURCE &&\
		terraform taint -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars -module=$$MODULE $$RESOURCE &&\
		terraform remote push
	@echo "You will now want to run a plan to see what changes will take place"

destroy: init update ## DANGER! Destroys a set of resources
	@terraform destroy -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars && terraform remote push

destroy-target: init update ## Specifically choose a resource to destroy
	@echo "Specifically destroy a piece of Terraform data"
	@echo "Example: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy this: " DATA &&\
		terraform destroy -var-file=../../environments/$(ENVIRONMENT)/$(ENVIRONMENT).tfvars -target=$$DATA &&\
		terraform remote push