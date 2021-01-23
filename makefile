# > CONSTANTS
PATTERN_BEGIN=»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
PATTERN_END=«««««««««««««««««««««««««««««««««««««««««««««

BUILDPACK_BUILDER=heroku/buildpacks:18

MODEL_NAME=model1

MODEL1_PACK_NAME=pack_energysim_model1
MODEL1_CONTAINER_NAME=cont_energysim_model1
MODEL1_BACKDOOR=3000
MODEL1_PORTS=8001:8000

RABBIT_CONTAINER_NAME=cont_energysim_rabbitmq
RABBIT_NETWORK_NAME=net_rabbitmq
RABBIT_USER=guest
RABBIT_PASSWORD=guest
RABBIT_PORT=5672
RABBIT_MANAGEMENT_PORT=15672
# < CONSTANTS

main: run-docker-model1

# > MODEL1
run-docker-model1: stop-docker-model1 build-docker-model1 start-docker-model1

build-docker-model1:
	@echo '$(PATTERN_BEGIN) BUILDING `$(MODEL_NAME)` PACK...'

	@pipreqs ./ --force
	@pack build $(MODEL1_PACK_NAME) \
	--builder $(BUILDPACK_BUILDER)

	@echo '$(PATTERN_END) `$(MODEL_NAME)` PACK BUILT!'

start-docker-model1:
	@echo '$(PATTERN_BEGIN) STARTING `$(MODEL_NAME)` PACK...'

	@docker run -d \
	--name $(MODEL1_CONTAINER_NAME) \
	--network $(RABBIT_NETWORK_NAME) \
	-e RABBIT_USER=$(RABBIT_USER) \
	-e RABBIT_PASSWORD=$(RABBIT_PASSWORD) \
	-e RABBIT_HOST=$(RABBIT_CONTAINER_NAME) \
	-e RABBIT_MANAGEMENT_PORT=$(RABBIT_MANAGEMENT_PORT) \
	-e RABBIT_PORT=$(RABBIT_PORT) \
	-p $(MODEL1_PORTS) \
	$(MODEL1_PACK_NAME)
	
	@echo '$(PATTERN_END) `$(MODEL_NAME)` PACK STARTED!'

stop-docker-model1:
	@echo '$(PATTERN_BEGIN) STOPPING `$(MODEL_NAME)` PACK...'

	@( docker stop $(MODEL1_CONTAINER_NAME) && docker rm $(MODEL1_CONTAINER_NAME) ) || true

	@echo '$(PATTERN_END) `$(MODEL_NAME)` PACK STOPPED!'	
# < GATEWAY

# > NAMEKO
run-nameko-model1: prep-nameko-model1 start-nameko-model1

prep-nameko-model1:
	@until nc -z $(RABBIT_CONTAINER_NAME) $(RABBIT_PORT); do \
	echo "$$(date) - waiting for rabbitmq..."; \
	sleep 2; \
	done

start-nameko-model1:
	@nameko run model1.service \
	--config nameko-config.yml  \
	--backdoor $(MODEL1_BACKDOOR)
# < NAMEKO