# This target is used by the GitHub PR checker to validate canonical syntax on all files.
#
.PHONY: structure-check
structure-check: generated-formatting rubocop-tests

.PHONY: generated-formatting
generated-formatting:
	$(eval FMT_ERR := $(shell terraform fmt -list -write=false .))
	@if [ "$(FMT_ERR)" != "" ]; then echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR); exit 1; fi

	@if $(MAKE) docs && ! git diff --exit-code; then echo "outdated docs (run 'make docs' to fix)"; exit 1; fi
	@if $(MAKE) examples && ! git diff --exit-code; then echo "outdated examples (run 'make examples' to fix)"; exit 1; fi
	@if $(TOP_DIR)/modules/update-payload/make-update-payload.sh && ! git diff --exit-code; then echo "outdated payload (run '$(TOP_DIR)/modules/update-payload/make-update-payload.sh' to fix)"; exit 1; fi

.PHONY: rubocop-tests
rubocop-tests:
	cd tests/rspec && rubocop