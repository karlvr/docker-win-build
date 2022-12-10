.PHONY: all
all: pull build

.PHONY: build
build:
	docker build . -t karlvr/win-build

.PHONY: pull
pull:
	docker pull ubuntu:22.04
