.PHONY: build build-dev sync sync-dev sync-dist

PREBID_VERSION ?= $(shell cat gannett-version.txt)

default: build

build:
	@echo "Building Prebid Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@yarn install --silent
	@git checkout -q master -- modules.json
	@gulp build --modules=modules.json --silent
	@git checkout -q master
	@echo "Prebid built to ./build/dist/prebid.js"

build-dev:
	@echo "Building Prebid Dev Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@yarn install --silent
	@git checkout -q master -- modules.json
	@gulp build-bundle-dev --modules=modules.json --silent
	@git checkout -q master
	@echo "Prebid dev built to ./build/dev/prebid.js"

sync-dist: build
	@gsutil cp build/dist/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich.min.js
	@curl -s -X PURGE "https://${FASTLY_PURGE_USER_CDN}:${FASTLY_PURGE_PASS_CDN}@www.gannett-cdn.com/partner/vendor/pbjsandwich.min.js" > /dev/null

sync-dev: build-dev
	@gsutil cp build/dev/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich.js
	@curl -s -X PURGE "https://${FASTLY_PURGE_USER_CDN}:${FASTLY_PURGE_PASS_CDN}@www.gannett-cdn.com/partner/vendor/pbjsandwich.js" > /dev/null

sync: sync-dev sync-dist
