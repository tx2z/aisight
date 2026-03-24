include .env
export

.PHONY: dev build deploy

dev:
	hugo server --port 1315

build:
	hugo

deploy: build
	npx wrangler deploy
