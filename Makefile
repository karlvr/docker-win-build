.PHONY: all
all: pull build

# We must build as amd64 as we use Wine which requires i386
# See https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
.PHONY: build
build:
	docker build . -t karlvr/win-build:v50

.PHONY: pull
pull:
	docker pull ubuntu:22.04

.PHONY: push
push:
	docker push karlvr/win-build:v50

.PHONY: run
run:
	docker run -it --rm karlvr/win-build:v50 bash
