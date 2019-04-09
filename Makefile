#
BUILDER_ARGS?="--without system_tests --path=${BUNDLE_PATH:-vendor/bundle}"

#
.PHONY: default



install:
	@echo ">>> bundle install ..."
	bundle install --path vendor/bundle

