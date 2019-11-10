.PHONY: help

help:
	@echo 'Available targets:'
	@echo '  make dockerize OR make ARGS="--build" dockerize'

dockerize:
	docker-compose up ${ARGS}
