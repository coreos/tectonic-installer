CLUSTER ?= demo
PLATFORM ?= aws
TMPDIR ?= /tmp
TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR = $(TOP_DIR)/build/$(CLUSTER)
INSTALLER_BIN = $(TOP_DIR)/installer/bin/$(shell uname | tr '[:upper:]' '[:lower:]')/installer
TF_DOCS := $(shell which terraform-docs 2> /dev/null)
TF_EXAMPLES := $(shell which terraform-examples 2> /dev/null)
TF_CMD = TERRAFORM_CONFIG=$(TOP_DIR)/.terraformrc terraform

$(info Using build directory [${BUILD_DIR}])

all: apply

$(INSTALLER_BIN):
	make build -C $(TOP_DIR)/installer

installer-env: $(INSTALLER_BIN) terraformrc.example
	sed "s|<PATH_TO_INSTALLER>|$(INSTALLER_BIN)|g" terraformrc.example > .terraformrc

localconfig:
	mkdir -p $(BUILD_DIR)

terraform-get:
	cd $(BUILD_DIR) && $(TF_CMD) get $(TOP_DIR)/platforms/$(PLATFORM)

plan: installer-env terraform-get
	cd $(BUILD_DIR) && $(TF_CMD) plan $(TOP_DIR)/platforms/$(PLATFORM)

apply: installer-env terraform-get
	cd $(BUILD_DIR) && TF_LOG=TRACE $(TF_CMD) apply $(TOP_DIR)/platforms/$(PLATFORM)

destroy: installer-env terraform-get
	cd $(BUILD_DIR) && $(TF_CMD) destroy -force $(TOP_DIR)/platforms/$(PLATFORM)

payload:
	@${TOP_DIR}/modules/update-payload/make-update-payload.sh > /dev/null

define terraform-docs
	$(if $(TF_DOCS),,$(error "terraform-docs revision >= a8b59f8 is required (https://github.com/segmentio/terraform-docs)"))

	@echo '<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->' > $1
	@echo '# Terraform variables' >> $1
	@echo $2 >> $1
	terraform-docs --no-required markdown $3 $4 $5 $6 >> $1
endef

define terraform-examples
	$(if $(TF_EXAMPLES),,$(error "terraform-examples revision >= 83d7ad6 is required (https://github.com/segmentio/terraform-docs)"))
	terraform-examples $2 $3 $4 $5 > $1
endef

docs:
	$(call terraform-docs, Documentation/variables/config.md, \
			'This document gives an overview of variables used in all platforms of the Tectonic SDK.', \
			config.tf)

	$(call terraform-docs, Documentation/variables/aws.md, \
			'This document gives an overview of variables used in the AWS platform of the Tectonic SDK.', \
			platforms/aws/variables.tf)

	$(call terraform-docs, Documentation/variables/azure.md, \
			'This document gives an overview of variables used in the Azure platform of the Tectonic SDK.', \
			platforms/azure/variables.tf)

	$(call terraform-docs, Documentation/variables/openstack-nova.md, \
			'This document gives an overview of variables used in the Openstack/Nova platform of the Tectonic SDK.', \
			platforms/openstack/nova/variables.tf)

	$(call terraform-docs, Documentation/variables/openstack-neutron.md, \
			'This document gives an overview of variables used in the Openstack/Neutron platform of the Tectonic SDK.', \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-docs, Documentation/variables/metal.md, \
			'This document gives an overview of variables used in the bare metal platform of the Tectonic SDK.', \
			platforms/metal/variables.tf)

examples:
	$(call terraform-examples, examples/terraform.tfvars.aws, \
			config.tf, \
			platforms/aws/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.azure, \
			config.tf, \
			platforms/azure/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.openstack-nova, \
			config.tf, \
			platforms/openstack/nova/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.openstack-neutron, \
			config.tf, \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.metal, \
			config.tf, \
			platforms/metal/variables.tf)

clean: destroy
	rm -rf $(BUILD_DIR)
	make clean -C $(TOP_DIR)/installer

# This target is used by the GitHub PR checker to validate canonical syntax on all files.
#
structure-check:
	$(eval FMT_ERR := $(shell terraform fmt -list -write=false .))
	@if [ "$(FMT_ERR)" != "" ]; then echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR); exit 1; fi

canonical-syntax:
	terraform fmt -list .

.PHONY: make clean terraform terraform-dev structure-check canonical-syntax docs examples terraform-get
