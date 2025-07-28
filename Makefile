.PHONY: all
all: pull build

.PHONY: build
build:
	docker build . -t karlvr/win-build:v50.1

.PHONY: pull
pull:
	docker pull ubuntu:25.10

.PHONY: push
push:
	docker push karlvr/win-build:v50.1

.PHONY: run
run:
	docker run -it --rm karlvr/win-build:v50.1 bash
