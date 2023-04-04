.PHONY: all
all: pull build

.PHONY: build
build:
	docker build . -t karlvr/win-build:v46

.PHONY: pull
pull:
	docker pull ubuntu:22.04

.PHONY: push
push:
	docker push karlvr/win-build:v46
