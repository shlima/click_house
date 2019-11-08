.PHONY: help

help:
	@echo 'Available targets:'
	@echo '  make dockerize OR make ARGS="--build" dockerize'

dockerize:
	rm -f tmp/pids/server.pid tmp/sockets/puma.sock
	docker-compose up ${ARGS}
