.PHONY: build test run down


build:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml build

up:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.dev.yml up

down:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.dev.yml down

down:
	docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.dev.yml down

tests:
	docker-compose -f docker-compose.yml -f docker-compose.tests.yml up --exit-code-from gleague gleague
