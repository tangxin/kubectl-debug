.PHONY: build plugin agent check

LDFLAGS = $(shell ./version.sh)
GOENV := GO15VENDOREXPERIMENT="1" GO111MODULE=on CGO_ENABLED=0 
GO := $(GOENV) go
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
DOKCER_REPO ?= kubeimages
MAKE := make -f multi.Makefile

buildx: pluginx agentx-docker

plugin:
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GOENV) go build -ldflags '$(LDFLAGS)' -o out/kubectl-debug-$(GOOS)-$(GOARCH) cmd/plugin/main.go

pluginx:
	GOOS=linux GOARCH=amd64 $(MAKE) plugin
	GOOS=linux GOARCH=arm64 $(MAKE) plugin
	GOOS=darwin GOARCH=amd64 $(MAKE) plugin

agent:
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GOENV) go build -ldflags '$(LDFLAGS)' -o out/debug-agent-$(GOOS)-$(GOARCH)  cmd/agent/main.go

agentx:
	GOOS=linux GOARCH=amd64 $(MAKE) agent
	GOOS=linux GOARCH=arm64 $(MAKE) agent
	GOOS=darwin GOARCH=amd64 $(MAKE) agent

agentx-docker: agentx
	docker buildx build --platform=linux/amd64,linux/arm64 \
		--push \
		-t $(DOKCER_REPO)/debug-agent \
		-f multi.Dockerfile \
		.

clean:
	rm -rf out/