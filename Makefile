.PHONY: help

help:
	@echo 'Available targets:'
	@echo '  make dockerize OR make ARGS="--build" dockerize'
	@echo '  make release'

dockerize:
	docker-compose up ${ARGS}

release:
	bin/release.sh
