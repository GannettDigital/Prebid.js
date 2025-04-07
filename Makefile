.PHONY: build build-dev sync sync-dev sync-dist sync-uw sync-sa sync-arkadium

PREBID_VERSION ?= $(shell cat gannett-version.txt)
PREFIX=

default: build

build:
	@echo "Building Prebid Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@npm ci
	@git checkout -q master -- modules${PREFIX}.json
	@gulp build --modules=modules${PREFIX}.json --silent
	@git checkout -q integrationExamples/gpt/x-domain/creative.html
	@git checkout -q master
	@echo "Prebid built to ./build/dist/prebid.js"

build-dev:
	@echo "Building Prebid Dev Version: $(PREBID_VERSION)"
	@git checkout -q tags/$(PREBID_VERSION)
	@npm ci
	@git checkout -q master -- modules${PREFIX}.json
	@gulp build-bundle-dev --modules=modules${PREFIX}.json --silent
	@git checkout -q integrationExamples/gpt/x-domain/creative.html
	@git checkout -q master
	@echo "Prebid dev built to ./build/dev/prebid.js"

sync-dist: build
	@gsutil cp build/dist/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich${PREFIX}.min.js
	@curl -s -X PURGE "https://${FASTLY_PURGE_USER_CDN}:${FASTLY_PURGE_PASS_CDN}@www.gannett-cdn.com/partner/vendor/pbjsandwich${PREFIX}.min.js" > /dev/null

sync-dev: build-dev
	@gsutil cp build/dev/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich${PREFIX}.js
	@curl -s -X PURGE "https://${FASTLY_PURGE_USER_CDN}:${FASTLY_PURGE_PASS_CDN}@www.gannett-cdn.com/partner/vendor/pbjsandwich${PREFIX}.js" > /dev/null


sync: sync-uw sync-sa sync-arkadium

sync-uw:
	$(MAKE) sync-dist PREFIX="-uw" PREBID_VERSION?=$(shell cat gannett-version-uw.txt)
	$(MAKE) sync-dev PREFIX="-uw" PREBID_VERSION?=$(shell cat gannett-version-uw.txt)
	$(MAKE) sync-dist PREFIX="-uw-noserv" PREBID_VERSION?=$(shell cat gannett-version-uw.txt)
	$(MAKE) sync-dev PREFIX="-uw-noserv" PREBID_VERSION?=$(shell cat gannett-version-uw.txt)

sync-sa:
	$(MAKE) sync-dist PREFIX="-sa" PREBID_VERSION?=$(shell cat gannett-version-sa.txt)
	$(MAKE) sync-dev PREFIX="-sa" PREBID_VERSION?=$(shell cat gannett-version-sa.txt)
	$(MAKE) sync-dist PREFIX="-sa-noserv" PREBID_VERSION?=$(shell cat gannett-version-sa.txt)
	$(MAKE) sync-dev PREFIX="-sa-noserv" PREBID_VERSION?=$(shell cat gannett-version-sa.txt)

sync-arkadium: sync-dist sync-dev
	$(MAKE) sync-dist PREFIX="-noserv"
	$(MAKE) sync-dev PREFIX="-noserv"
