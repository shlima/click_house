.PHONY: help

.BUNDLE_GEMFILE:=
.REQUIRE:=./spec/spec_helper

help:
	@echo 'Available targets:'
	@echo '  make dockerize OR make ARGS="--build" dockerize'
	@echo '  make release'
	@echo '  '
	@echo '  make faraday1 bundle'
	@echo '  make faraday2 bundle'
	@echo '  '
	@echo '  make faraday1 rspec'
	@echo '  make faraday2 rspec'
	@echo '  make faraday2 oj rspec'

dockerize:
	docker-compose up ${ARGS}

release:
	bin/release.sh

faraday1:
	$(eval .BUNDLE_GEMFILE=Gemfile_faraday1)

faraday2:
	$(eval .BUNDLE_GEMFILE=Gemfile_faraday2)

oj:
	$(eval .REQUIRE=./spec/oj_helper)

bundle:
	BUNDLE_GEMFILE=${.BUNDLE_GEMFILE} bundle

rspec:
	BUNDLE_GEMFILE=${.BUNDLE_GEMFILE} rspec --require ${.REQUIRE} spec