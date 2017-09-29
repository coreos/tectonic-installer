CLUSTER ?= demo
PLATFORM ?= aws
TMPDIR ?= /tmp
GOOS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
GOARCH=amd64
TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR = $(TOP_DIR)/build/$(CLUSTER)
PLUGIN_DIR = $(BUILD_DIR)/terraform.d/plugins/$(GOOS)_$(GOARCH)
INSTALLER_PATH = $(TOP_DIR)/installer/bin/$(shell uname | tr '[:upper:]' '[:lower:]')
INSTALLER_BIN = $(INSTALLER_PATH)/installer
TF_DOCS := $(shell which terraform-docs 2> /dev/null)
TF_EXAMPLES := $(shell which terraform-examples 2> /dev/null)
TF_CMD = terraform
TEST_COMMAND = /bin/bash -c "bundler exec rspec spec/${TEST}"

include ./makelib/*.mk

$(info Using build directory [${BUILD_DIR}])

.PHONY: all
all: $(INSTALLER_BIN) custom-providers

$(INSTALLER_BIN):
	$(MAKE) build -C $(TOP_DIR)/installer

.PHONY: localconfig
localconfig:
	mkdir -p $(BUILD_DIR)
	cp examples/*$(subst /,-,$(PLATFORM)) $(BUILD_DIR)/terraform.tfvars

$(PLUGIN_DIR):
	mkdir -p $(PLUGIN_DIR)
	ln -s $(INSTALLER_PATH)/terraform-provider-* $(PLUGIN_DIR)

.PHONY: terraform-init
terraform-init: custom-providers $(PLUGIN_DIR)
ifneq ($(shell $(TF_CMD) version | grep -E "Terraform v0\.1[0-9]\.[0-9]+"), )
	cd $(BUILD_DIR) && $(TF_CMD) init $(TF_INIT_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)
else
	cd $(BUILD_DIR) && $(TF_CMD) get $(TF_GET_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)
endif

.PHONY: plan
plan: terraform-init
	cd $(BUILD_DIR) && $(TF_CMD) plan $(TF_PLAN_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: apply
apply: terraform-init
	cd $(BUILD_DIR) && $(TF_CMD) apply $(TF_APPLY_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: destroy
destroy: terraform-init
	cd $(BUILD_DIR) && $(TF_CMD) destroy $(TF_DESTROY_OPTIONS) -force $(TOP_DIR)/platforms/$(PLATFORM)

define terraform-docs
	$(if $(TF_DOCS),,$(error "terraform-docs revision >= a8b59f8 is required (https://github.com/segmentio/terraform-docs)"))

	@echo '<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->' > $1
	@echo '# Terraform variables' >> $1
	@echo $2 >> $1
	terraform-docs --no-required markdown $3 $4 $5 $6 >> $1
endef

define terraform-examples
	$(if $(TF_EXAMPLES),,$(error "terraform-examples revision >= 83d7ad6 is required (https://github.com/s-urbaniak/terraform-examples)"))
	terraform-examples $2 $3 $4 $5 > $1
endef

.PHONY: docs
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

	$(call terraform-docs, Documentation/variables/openstack-neutron.md, \
			'This document gives an overview of variables used in the Openstack/Neutron platform of the Tectonic SDK.', \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-docs, Documentation/variables/metal.md, \
			'This document gives an overview of variables used in the bare metal platform of the Tectonic SDK.', \
			platforms/metal/variables.tf)

	$(call terraform-docs, Documentation/variables/vmware.md, \
			'This document gives an overview of variables used in the VMware platform of the Tectonic SDK.', \
			platforms/vmware/variables.tf)

	$(call terraform-docs, Documentation/variables/gcp.md, \
			'This document gives an overview of variables used in the Google Cloud platform of the Tectonic SDK.', \
			platforms/gcp/variables.tf)

.PHONY: examples
examples:
	$(call terraform-examples, examples/terraform.tfvars.aws, \
			config.tf, \
			platforms/aws/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.azure, \
			config.tf, \
			platforms/azure/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.openstack-neutron, \
			config.tf, \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.metal, \
			config.tf, \
			platforms/metal/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.vmware, \
			config.tf, \
			platforms/vmware/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.gcp, \
			config.tf, \
			platforms/gcp/variables.tf)
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) clean -C $(TOP_DIR)/installer
	rm -f $(TF_RC)

# This target is used by the GitHub PR checker to validate canonical syntax on all files.
#
.PHONY: structure-check
structure-check:
	$(eval FMT_ERR := $(shell terraform fmt -list -write=false .))
	@if [ "$(FMT_ERR)" != "" ]; then echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR); exit 1; fi

	@if $(MAKE) docs && ! git diff --exit-code; then echo "outdated docs (run 'make docs' to fix)"; exit 1; fi
	@if $(MAKE) examples && ! git diff --exit-code; then echo "outdated examples (run 'make examples' to fix)"; exit 1; fi

SMOKE_SOURCES := $(shell find $(TOP_DIR)/tests/smoke -name '*.go')
.PHONY: bin/smoke
bin/smoke: $(SMOKE_SOURCES)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go test ./tests/smoke/ -c -o bin/smoke

.PHONY: vendor-smoke
vendor-smoke: $(TOP_DIR)/tests/smoke/glide.yaml
	@cd $(TOP_DIR)/tests/smoke && glide up -v
	@cd $(TOP_DIR)/tests/smoke && glide-vc --use-lock-file --no-tests --only-code

.PHONY: e2e-docker-image
e2e-docker-image: images/kubernetes-e2e/Dockerfile
	  @E2E_IMAGE="quay.io/coreos/kube-conformance:$$(grep "ARG E2E_REF" $< | cut -d "=" -f2 | sed 's/+/_/') \
	  echo "Building E2E image $${E2E_IMAGE}"; \
	  docker build -t $${E2E_IMAGE} $(dir $<)

.PHONY: smoke-test-env-docker-image
smoke-test-env-docker-image:
	docker build -t quay.io/coreos/tectonic-smoke-test-env -f images/tectonic-smoke-test-env/Dockerfile .

.PHONY: tests/smoke
tests/smoke: bin/smoke smoke-test-env-docker-image
	docker run \
	--rm \
	-it \
	-v "${CURDIR}":"${CURDIR}" \
	-w "${CURDIR}/tests/rspec" \
	-v "${TF_VAR_tectonic_license_path}":"${TF_VAR_tectonic_license_path}" \
	-v "${TF_VAR_tectonic_pull_secret_path}":"${TF_VAR_tectonic_pull_secret_path}" \
	-v "${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}" \
	-v "${TF_VAR_tectonic_azure_ssh_key}":"${TF_VAR_tectonic_azure_ssh_key}" \
	-e SSH_AUTH_SOCK \
	-e CLUSTER \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e ARM_CLIENT_ID \
	-e ARM_CLIENT_SECRET \
	-e ARM_ENVIRONMENT \
	-e ARM_SUBSCRIPTION_ID \
	-e ARM_TENANT_ID \
	-e GOOGLE_APPLICATION_CREDENTIALS \
	-e GOOGLE_CREDENTIALS \
	-e GOOGLE_CLOUD_KEYFILE_JSON \
	-e GCLOUD_KEYFILE_JSON \
	-e TF_VAR_tectonic_aws_region \
	-e TF_VAR_tectonic_aws_ssh_key \
	-e TF_VAR_tectonic_azure_location \
	-e TF_VAR_tectonic_license_path \
	-e TF_VAR_tectonic_pull_secret_path \
	-e TF_VAR_base_domain \
	-e TECTONIC_TESTS_DONT_CLEAN_UP \
	--cap-add NET_ADMIN \
	--device /dev/net/tun \
	quay.io/coreos/tectonic-smoke-test-env \
	$(TEST_COMMAND)
