TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

TERRAFORM_REPOSITORY=https://github.com/coreos/terraform.git
TERRAFORM_RELEASE_URL=https://api.github.com/repos/coreos/terraform/releases/latest
TERRAFORM_BRANCH=v0.8.8-coreos
TERRAFORM_BUILD_DIR=$(TOP_DIR)/build/terraform
TERRAFORM_BINS_DIR=$(TOP_DIR)/bin/terraform
TERRAFORM_GO_IMAGE=golang:1.8
TERRAFORM_GO_OS=linux darwin windows
TERRAFORM_GOARCH=386 amd64

PATH  := $(TOP_DIR)/bin/terraform:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash
$(info Using TerraForm binary [$(shell which terraform 2> /dev/null)])

ifeq ($(OS), Windows_NT)
    GOOS = windows
    ifeq ($(PROCESSOR_ARCHITECTURE), AMD64)
        GOARCH = amd64
    else ifeq ($(PROCESSOR_ARCHITECTURE), x86)
        GOARCH = 386
    endif
else
    OS := $(shell uname -s)
    ARCH := $(shell uname -m)
    ifeq ($(OS), Linux)
        GOOS = linux
    else ifeq ($(OS), Darwin)
        GOOS = darwin
    endif
    ifeq ($(ARCH), x86_64)
        GOARCH = amd64
    else ifneq ($(filter %86, $(ARCH)),)
        GOARCH = 386
    else ifneq ($(findstring arm, $(ARCH)),)
        GOARCH = arm
    endif
endif

$(TERRAFORM_BINS_DIR):
	mkdir -p $(TERRAFORM_BINS_DIR)

$(TERRAFORM_BUILD_DIR):
	git clone -b $(TERRAFORM_BRANCH) $(TERRAFORM_REPOSITORY) $(TERRAFORM_BUILD_DIR)

terraform-dev:
	make terraform TERRAFORM_GO_OS=$(GOOS) TERRAFORM_GOARCH=$(GOARCH)

terraform: $(TERRAFORM_BUILD_DIR) $(TERRAFORM_BINS_DIR)
	docker run --rm -v $(TERRAFORM_BUILD_DIR):/go/src/github.com/hashicorp/terraform \
		-w /go/src/github.com/hashicorp/terraform \
		-e XC_OS="$(TERRAFORM_GO_OS)" -e XC_ARCH="$(TERRAFORM_GOARCH)" \
		$(TERRAFORM_GO_IMAGE) make bin
	cp -r $(TERRAFORM_BUILD_DIR)/pkg/* $(TERRAFORM_BINS_DIR)
	cp $(TERRAFORM_BUILD_DIR)/pkg/$(GOOS)_$(GOARCH)/terraform $(TERRAFORM_BINS_DIR)
	cd $(TERRAFORM_BINS_DIR) && zip -r terraform.zip */
	echo -e "\n--> TerraForm built successfully for [$(TERRAFORM_GO_OS)] / [$(TERRAFORM_GOARCH)] in $(TERRAFORM_BINS_DIR)"

terraform-download: $(TERRAFORM_BINS_DIR)
	curl -L `curl -s $(TERRAFORM_RELEASE_URL) | grep browser_download_url | head -n 1 | cut -d '"' -f 4` > $(TERRAFORM_BINS_DIR)/terraform.zip
	cd $(TERRAFORM_BINS_DIR) && unzip -o terraform.zip
	cp $(TERRAFORM_BINS_DIR)/$(GOOS)_$(GOARCH)/terraform $(TERRAFORM_BINS_DIR)

terraform-clean:
	rm -rf $(TERRAFORM_BUILD_DIR) $(TERRAFORM_BINS_DIR)
