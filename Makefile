.PHONY: all
all: build

.PHONY: build
build:
	docker buildx build --pull . -t karlvr/win-build:latest

.PHONY: push
push:
	docker push karlvr/win-build:latest

.PHONY: run
run:
	docker run -it --rm karlvr/win-build:latest bash
