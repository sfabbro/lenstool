
DEVNAME = lenstool

NAME = images.canfar.net/skaha/$(DEVNAME)
VERSION = 8.0.4

build: dependencies Dockerfile
	docker build -t $(NAME):$(VERSION) --build-arg LENSTOOL_VERSION=$(VERSION) -f Dockerfile .

dependencies: 

init:
	mkdir -p build

.PHONY: clean
clean:
	\rm -rf build
