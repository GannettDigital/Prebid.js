.PHONY: build build-dev sync sync-dev sync-dist

PREBID_VERSION ?= $(shell cat gannett-version.txt)

default: build

build:
	@echo "Building Prebid Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@yarn install --silent
	@git checkout -q master -- modules.json
	@echo "Checking out aolBidAdapter from Prebid 1.15.0"
	@git checkout -q tags/1.15.0 -- modules/aolBidAdapter.js
	@gulp build --modules=modules.json
	@git checkout -q master
	@git checkout -q HEAD -- modules/aolBidAdapter.js
	@echo "Prebid built to ./build/dist/prebid.js"

build-dev:
	@echo "Building Prebid Dev Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@yarn install --silent
	@git checkout -q master -- modules.json
	@echo "Checking out aolBidAdapter from Prebid 1.15.0"
	@git checkout -q tags/1.15.0 -- modules/aolBidAdapter.js
	@gulp build-bundle-dev --modules=modules.json
	@git checkout -q master
	@git checkout -q HEAD -- modules/aolBidAdapter.js
	@echo "Prebid dev built to ./build/dev/prebid.js"

sync-dist: build
	@gsutil cp build/dist/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich.min.js
	@curl -s -X PURGE https://www.gannett-cdn.com/ads/vendor/pbjsandwich.min.js > /dev/null

sync-dev: build-dev
	@gsutil cp build/dev/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich.js
	@curl -s -X PURGE https://www.gannett-cdn.com/ads/vendor/pbjsandwich.js > /dev/null

sync: sync-dev sync-dist
