CLUSTER ?= demo
PLATFORM ?= aws
TMPDIR ?= /tmp
TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR = $(TOP_DIR)/build/$(CLUSTER)
INSTALLER_BIN = $(TOP_DIR)/installer/bin/$(shell uname | tr '[:upper:]' '[:lower:]')/installer
TF_DOCS := $(shell which terraform-docs 2> /dev/null)
TF_CMD = TERRAFORM_CONFIG=$(TOP_DIR)/.terraformrc terraform

$(info Using build directory [${BUILD_DIR}])

all: apply

$(INSTALLER_BIN):
	make build -C $(TOP_DIR)/installer

installer-env: $(INSTALLER_BIN) terraformrc.example	
	sed "s|<PATH_TO_INSTALLER>|$(INSTALLER_BIN)|g" terraformrc.example > .terraformrc

localconfig:
	mkdir -p $(BUILD_DIR)
	touch $(BUILD_DIR)/terraform.tfvars

$(BUILD_DIR)/.terraform:
	cd $(BUILD_DIR) && $(TF_CMD) get $(TOP_DIR)/platforms/$(PLATFORM)

plan: installer-env $(BUILD_DIR)/.terraform
	cd $(BUILD_DIR) && $(TF_CMD) plan $(TOP_DIR)/platforms/$(PLATFORM)

apply: installer-env $(BUILD_DIR)/.terraform
	cd $(BUILD_DIR) && $(TF_CMD) apply $(TOP_DIR)/platforms/$(PLATFORM)

destroy: installer-env ${BUILD_DIR}/.terraform
	cd $(BUILD_DIR) && $(TF_CMD) destroy -force $(TOP_DIR)/platforms/$(PLATFORM)

terraform-check:
	@terraform-docs >/dev/null 2>&1 || @echo "terraform-docs is required (https://github.com/segmentio/terraform-docs)"

.PHONY: docs
docs: \
	Documentation/variables/config.md \
	Documentation/variables/aws.md \
	Documentation/variables/azure.md \
	Documentation/variables/metal.md \
	Documentation/variables/openstack-nova.md \
	Documentation/variables/openstack-neutron.md

Documentation/variables/config.md: config.tf
ifndef TF_DOCS
	$(error "terraform-docs is required (https://github.com/segmentio/terraform-docs)")
endif
	@echo '<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->' > $@
	@echo '# Terraform variables' >> $@
	@echo 'This document gives an overview of the variables used in the different platforms of the Tectonic SDK.' >> $@
	terraform-docs markdown config.tf >> $@

Documentation/variables/%.md: platforms/**/*.tf
ifndef TF_DOCS
	$(error "terraform-docs is required (https://github.com/segmentio/terraform-docs)")
endif

	$(eval PLATFORM_DIR := $(subst -,/,$*))
	@echo $(PLATFORM_DIR)
	@echo '<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->' > $@
	@echo '# Terraform variables' >> $@
	@echo 'This document gives an overview of the variables used in the different platforms of the Tectonic SDK.' >> $@
	terraform-docs markdown platforms/$(PLATFORM_DIR)/variables.tf >> $@

docs: Documentation/variables/config.md Documentation/variables/aws.md Documentation/variables/azure.md Documentation/variables/openstack-nova.md Documentation/variables/openstack-neutron.md

clean: destroy
	rm -rf $(BUILD_DIR)

# This target is used by the GitHub PR checker to validate canonical syntax on all files.
#
structure-check: 
	$(eval FMT_ERR := $(shell terraform fmt -list -write=false .))
	@if [ "$(FMT_ERR)" != "" ]; then echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR); exit 1; fi

canonical-syntax:
	terraform fmt -list .

.PHONY: make clean terraform terraform-dev structure-check canonical-syntax
