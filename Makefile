.PHONY: test release clean

DOCKER_HOST ?= localhost

test:
	docker-compose build --pull release
	docker-compose run test

release:
	docker-compose up --exit-code-from migrate migrate
	docker-compose run app python3 manage.py collectstatic --no-input
	docker-compose up -d app
	@ echo App running at http://$$(docker-compose port app 8000 | sed s/0.0.0.0/$(DOCKER_HOST)/g)

clean:
	docker-compose down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f ARGS