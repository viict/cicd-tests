NS = viict
VERSION ?= latest

REPO = testing
NAME = testing
CONTAINER = api
INSTANCE = default
PORTS = -p 3000:3000
ENV = \
  -e NODE_ENV=development

.PHONY: build push test

build:
	docker build \
  --cache-from $(NS)/$(REPO):$(CONTAINER)-$(VERSION) \
  --cache-from $(NS)/$(REPO):$(CONTAINER)-latest \
  --tag $(NS)/$(REPO):$(CONTAINER)-$(VERSION) \
  .

push:
	docker push $(NS)/$(REPO):$(CONTAINER)-$(VERSION)

test:
	docker run -itd --rm $(NS)/$(REPO):$(CONTAINER)-$(VERSION) yarn test

fast_track:
	../docker/fast_track $(NS)/$(REPO) $(CONTAINER)-$(VERSION)

default: build
