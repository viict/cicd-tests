NS = viict
VERSION ?= latest

REPO = testing
NAME = testing
CONTAINER = api
INSTANCE = default
PORTS = -p 3000:3000
ENV = \
  -e NODE_ENV=development

build:
	docker build \
  --cache-from $(NS)/$(REPO):$(CONTAINER)-$(VERSION) \
  --cache-from $(NS)/$(REPO):$(CONTAINER)-latest \
  --tag $(NS)/$(REPO):$(CONTAINER)-$(VERSION) \
  .

save:
	docker save $(NS)/$(REPO):$(CONTAINER)-$(VERSION) | gzip > $(CONTAINER).tgz

restore:
	docker load < $(CONTAINER).tgz

push:
	docker push $(NS)/$(REPO):$(CONTAINER)-$(VERSION)

test:
	docker run -it --rm $(NS)/$(REPO):$(CONTAINER)-$(VERSION) yarn test

fast_track:
	echo "TRUE"

default: build
