#!/usr/bin/make -f

MKFILE_RELPATH := $(shell printf -- '%s' '$(MAKEFILE_LIST)' | sed 's|^\ ||')
MKFILE_ABSPATH := $(shell readlink -f -- '$(MKFILE_RELPATH)')
MKFILE_DIR := $(shell dirname -- '$(MKFILE_ABSPATH)')

DOCKER_NAME = hblock-resolver
DOCKER_TAG = latest
DOCKER_IMAGE = $(DOCKER_NAME):$(DOCKER_TAG)
DOCKER_IMAGE_TARBALL = $(DOCKER_NAME).$(DOCKER_TAG).tgz
DOCKER_CONTAINER = $(DOCKER_NAME)
DOCKER_VOLUME = $(DOCKER_NAME)-data
DOCKERFILE = $(MKFILE_DIR)/Dockerfile

.PHONY: all \
	build build-image save-image \
	clean clean-image clean-container clean-volume clean-dist

all: build

build: save-image

build-image:
	docker build \
		--tag '$(DOCKER_IMAGE)' \
		--file '$(DOCKERFILE)' \
		'$(MKFILE_DIR)'

save-image: build-image
	mkdir -p dist
	docker save -- '$(DOCKER_IMAGE)' | gzip > 'dist/$(DOCKER_IMAGE_TARBALL)'

clean: clean-image clean-volume clean-dist

clean-image: clean-container
	-docker rmi -- '$(DOCKER_IMAGE)'

clean-container:
	-docker stop -- '$(DOCKER_CONTAINER)'
	-docker rm -- '$(DOCKER_CONTAINER)'

clean-volume:
	-docker volume rm -- '$(DOCKER_VOLUME)'

clean-dist:
	rm -f 'dist/$(DOCKER_IMAGE_TARBALL)'
	-rmdir dist
