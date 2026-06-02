.PHONY: help init plan apply destroy fmt validate clean lambda-deps
.DEFAULT_GOAL := help

ENV ?= dev
SHARED_VARS = -var-file=environments/_shared.tfvars
ENV_VARS    = -var-file=environments/$(ENV).tfvars

help:
	@echo "Usage: make <target> ENV=<dev|staging|prod>"
	@echo ""
	@echo "Targets:"
	@echo "  lambda-deps  Install npm deps for every Lambda source dir"
	@echo "  init         Initialize terraform with the env-specific backend"
	@echo "  plan         Plan against the selected env"
	@echo "  apply        Apply to the selected env"
	@echo "  destroy      Destroy the selected env (asks twice for prod)"
	@echo "  fmt          Format all .tf files"
	@echo "  validate     Validate terraform syntax"
	@echo "  clean        Remove .terraform and build artifacts"

lambda-deps:
	@for d in lambda-source/*/; do \
		echo "==> installing deps in $$d"; \
		(cd "$$d" && npm install --omit=dev --silent); \
	done

init:
	terraform init -reconfigure -backend-config=environments/$(ENV).backend.hcl

plan:
	terraform plan $(SHARED_VARS) $(ENV_VARS) -out=$(ENV).tfplan

apply:
	@if [ "$(ENV)" = "prod" ]; then \
		read -p "About to apply to PROD. Type 'apply-prod' to confirm: " confirm; \
		[ "$$confirm" = "apply-prod" ] || (echo "Aborted." && exit 1); \
	fi
	terraform apply $(ENV).tfplan

destroy:
	@if [ "$(ENV)" = "prod" ]; then \
		read -p "About to DESTROY PROD. Type 'destroy-prod' to confirm: " confirm; \
		[ "$$confirm" = "destroy-prod" ] || (echo "Aborted." && exit 1); \
	fi
	terraform destroy $(SHARED_VARS) $(ENV_VARS)

fmt:
	terraform fmt -recursive

validate:
	terraform validate

clean:
	rm -rf .terraform .terraform.lock.hcl *.tfplan
	find modules -name ".builds" -type d -exec rm -rf {} +
	find lambda-source -name "node_modules" -type d -exec rm -rf {} +
