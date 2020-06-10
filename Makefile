.PHONY: build test run down


build:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml build

up:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.dev.yml up

down:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.dev.yml down
