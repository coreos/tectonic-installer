CLUSTER ?= demo
TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR = $(TOP_DIR)/build/$(CLUSTER)
TEST_COMMAND = /bin/bash -c "bundler exec rspec spec/${TEST}"

$(info Using build directory [${BUILD_DIR}])

.PHONY: e2e-docker-image
e2e-docker-image: images/kubernetes-e2e/Dockerfile
	  @export E2E_IMAGE="quay.io/coreos/kube-conformance:$$(grep 'ARG E2E_REF' $< | cut -d '=' -f2 | sed 's/+/_/')"; \
	  echo "Building E2E image $${E2E_IMAGE}"; \
	  docker build -t $${E2E_IMAGE} $(dir $<)

.PHONY: smoke-test-env-docker-image
smoke-test-env-docker-image:
	docker build -t quay.io/coreos/tectonic-smoke-test-env -f images/tectonic-smoke-test-env/Dockerfile .

.PHONY: tests/smoke
tests/smoke: smoke-test-env-docker-image
	docker run \
	--rm \
	-it \
	-v "${CURDIR}":"${CURDIR}" \
	-w "${CURDIR}/tests/rspec" \
	-v "${TF_VAR_tectonic_license_path}":"${TF_VAR_tectonic_license_path}" \
	-v "${TF_VAR_tectonic_pull_secret_path}":"${TF_VAR_tectonic_pull_secret_path}" \
	-v "${HOME}/.ssh:/root/.ssh:ro" \
	-v "/var/run/docker.sock:/var/run/docker.sock" \
	-v "${TF_VAR_tectonic_azure_ssh_key}":"${TF_VAR_tectonic_azure_ssh_key}" \
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
	-e GOOGLE_PROJECT \
	-e TF_VAR_tectonic_gcp_ssh_key \
	-e TF_VAR_tectonic_aws_region \
	-e TF_VAR_tectonic_aws_ssh_key \
	-e TF_VAR_tectonic_azure_location \
	-e TF_VAR_tectonic_license_path \
	-e TF_VAR_tectonic_pull_secret_path \
	-e TF_VAR_tectonic_base_domain \
	-e TF_VAR_tectonic_admin_email \
	-e TF_VAR_tectonic_admin_password \
	-e TECTONIC_TESTS_DONT_CLEAN_UP \
	-e RUN_SMOKE_TESTS \
	-e RUN_CONFORMANCE_TESTS \
	-e KUBE_CONFORMANCE_IMAGE \
	-e COMPONENT_TEST_IMAGES \
	--cap-add NET_ADMIN \
	--device /dev/net/tun \
	quay.io/coreos/tectonic-smoke-test-env \
	$(TEST_COMMAND)
