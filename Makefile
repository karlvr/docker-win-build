.PHONY: all
all: pull build

.PHONY: build
build:
	docker build . -t karlvr/win-build:v50

.PHONY: pull
pull:
	docker pull ubuntu:24.04

.PHONY: push
push:
	docker push karlvr/win-build:v50

.PHONY: run
run:
	docker run -it --rm karlvr/win-build:v50 bash
