.PHONY: infra plan

infra:
	docker compose run --rm terraform init

plan:
	docker compose run --rm terraform plan -out=tfplan

apply:
	docker compose run --rm terraform apply tfplan

destroy:
	docker compose run --rm terraform destroy
