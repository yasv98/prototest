COLOUR_NORMAL=$(shell tput sgr0)
COLOUR_RED=$(shell tput setaf 1)
COLOUR_GREEN=$(shell tput setaf 2)

export GOLANG_VERSION=1.18.7
export GOPATH=$(shell go env GOPATH)

export FMT_IMAGE=gcr.io/anz-x-fabric-np-641432/fabric-cli:ce7f6ef974389a16428f444f437d4040366725b8

# Code coverage is low until more code is added, target will be 90.01
COVERAGE?=90.1
COVER_BADGE_FAIL="../docs/assets/coverage-failing.svg"
COVER_BADGE_PASS="../docs/assets/coverage-passing.svg"
COVER_BADGE_ASSET_PATH?=./assets/coverage.svg
LINT_BADGE_PASS="../docs/assets/lint-passing.svg"
LINT_BADGE_FAIL="../docs/assets/lint-failing.svg"
LINT_BADGE_ASSET_PATH?=./assets/lint.svg
MINIMUM_COVERAGE?=95.0

OUT_DIR?=./tmp
COVER_RAW_OUTPUT?=${OUT_DIR}/coverage.out
COVER_HTML_OUTPUT?=${OUT_DIR}/coverage.html

DOCKER_RUN_GO=docker run --rm \
               -e GOCACHE=/cache/go-build \
			   -v "$$PWD":/app:cached \
			   -v "$$(go env GOCACHE)":/cache/go-build:delegated \
			   -v ${GOPATH}/pkg:/go/pkg:delegated \
			   -w /app \
			   hub.artifactory.gcp.anz/golang:$(GOLANG_VERSION)

# -- HELPERS ------------------------------------------------------------

.PHONY: all
all: clean tidy lint test ## Perform clean, tidy, build, lint, and test
	@if [[ -e .git/rebase-merge ]]; then git --no-pager log -1 --pretty='%h %s'; fi
	@printf '%sSuccess%s\n' "${COLOUR_GREEN}" "${COLOUR_NORMAL}"
	@echo "Run make help to view more commands"

.PHONY: clean
clean: ## Run go clean and remove generated binaries and coverage files
	go clean ./...
	rm -Rf ${COVER_RAW_OUTPUT} ${COVER_HTML_OUTPUT} ${OUT_DIR} ./dist/* blackbox.test

.PHONY: fmt
fmt: ## Run fab fmt on all the source code
	docker run --rm \
		-v "$$PWD":/src \
		${FMT_IMAGE} \
		fmt --verbose=0 /src

.PHONY: lint-basic
lint-basic: ## Reorder imports and run golangci-lint
	goimports -d -e -w .
	docker run --rm \
	-e CONFIG_FILE=/pkg/.golangci.yaml \
	-v "$$(dirname $$PWD)":/pkg:cached \
	-e GOPROXY=https://platform-gomodproxy.services.x.gcpnp.anz \
    -e GONOSUMDB="github.com/anzx/*" \
    -e DOWNLOAD_MODE=readonly \
    -e GOCACHE=/cache/go \
    -e GOLANGCI_LINT_CACHE=/cache/go \
    -e VERBOSE=true \
    -v "$$(go env GOCACHE)":/cache/go:delegated \
    -v "$$PWD":/app:cached \
    -w /app \
    fabric-github-actions.artifactory.gcp.anz/golangci-lint:v1.49.0-1

.PHONY: lint
lint: ## Reorder imports and run golangci-lint
	goimports -d -e -w .
	docker run --rm \
	-e GOPROXY=https://platform-gomodproxy.services.x.gcpnp.anz \
    -e GONOSUMDB="github.com/anzx/*" \
    -e DOWNLOAD_MODE=readonly \
    -e GOCACHE=/cache/go-build \
    -e GOLANGCI_LINT_CACHE=/cache/go-build \
    -e VERBOSE=true \
    -v "$$(go env GOCACHE)":/cache/go-build:delegated \
    -v "$$PWD":/app:cached \
    -w /app \
    fabric-github-actions.artifactory.gcp.anz/golangci-lint:v1.49.0-1

.PHONY: tidy
tidy: ## Tidy go dependencies
	go mod tidy

# -- TESTING ------------------------------------------------------------

.PHONY: test
test: ## Test currently checked out code
	go test ./... -short

.PHONY: test-cover
test-cover: ## Test coverage of the currently checked out code using a locked version of Golang
	$(DOCKER_RUN_GO) make test-cover-local

.PHONY: test-cover-local
test-cover-local: ## Test coverage of the currently checked out code using the locally installed version of Golang
	mkdir -p ${OUT_DIR}
	go test -covermode=atomic -coverprofile=${COVER_RAW_OUTPUT} ./... -short
	@go tool cover -func=$(COVER_RAW_OUTPUT) | $(CHECK_COVERAGE)

.PHONY: test-cover-visual
test-cover-visual: ## Visual test coverage of the currently checked out code using a locked version of Golang
	$(DOCKER_RUN_GO) make test-cover-visual-local

.PHONY: test-cover-visual-local
test-cover-visual-local: test-cover-local ## Visual test coverage of the currently checked out code using the locally installed version of Golang
	go tool cover -html=$(COVER_RAW_OUTPUT) -o $(COVER_HTML_OUTPUT)

.PHONY: create-test-coverprofile
create-test-coverprofile:
	mkdir -p ${OUT_DIR}
	go test -covermode=atomic -coverprofile=${COVER_RAW_OUTPUT} ./... -short

.PHONY: create-cover-badge
create-cover-badge:
	$(eval COVERAGERESULT=$(shell go tool cover -func=$(COVER_RAW_OUTPUT) |  grep total | awk '{print substr($$3, 1, length($$3)-1)}'))
	$(eval COMPARISONRESULT=$(shell echo ${COVERAGERESULT}\>=${MINIMUM_COVERAGE} | bc))
	@if [ ${COMPARISONRESULT} == 0 ]; then \
		sed 's/replaceme/${COVERAGERESULT}/g' $(COVER_BADGE_FAIL) > $(COVER_BADGE_ASSET_PATH); \
	else \
		sed 's/replaceme/${COVERAGERESULT}/g' $(COVER_BADGE_PASS) > $(COVER_BADGE_ASSET_PATH); \
	fi

.PHONY: create-lint-badge
create-lint-badge:
	@if (make -s lint > /dev/null 2>&1); then \
		cp ${LINT_BADGE_PASS} ${LINT_BADGE_ASSET_PATH}; \
	else \
		cp ${LINT_BADGE_FAIL} ${LINT_BADGE_ASSET_PATH}; \
	fi

# -- UTILS --------------------------------------------------------------

.DEFAULT_GOAL := help
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort -d | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo "\nCoverage expected: ${COLOUR_GREEN}${COVERAGE}%${COLOUR_NORMAL}"

define CHECK_COVERAGE
awk \
  -F '[ 	%]+' \
  -v threshold="$(COVERAGE)" \
  '/^total:/ { print; if ($$3 < threshold) { exit 1 } }' || { \
	printf '%sFAIL - Coverage below %s%%%s\n' \
	  "$(COLOUR_RED)" "$(COVERAGE)" "$(COLOUR_NORMAL)"; \
	exit 1; \
  }
endef