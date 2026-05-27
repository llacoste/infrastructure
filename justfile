set dotenv-load := false
set shell := ["bash", "-uc"]

terraform := "op run --env-file=.env.tpl -- terraform"

default:
    @just --list

fmt:
    terraform fmt -recursive

fmt-check:
    terraform fmt -check -recursive

init:
    {{terraform}} init

validate: init
    {{terraform}} validate

plan: init
    {{terraform}} plan -out=.terraform/plan

apply:
    {{terraform}} apply .terraform/plan

check-redirects:
    @for domain in llacoste.dev lancelacoste.dev llacoste.com; do \
      printf '%s\n' "https://$domain"; \
      curl --fail --silent --show-error --head "https://$domain"; \
      printf '%s\n' "https://www.$domain"; \
      curl --fail --silent --show-error --head "https://www.$domain"; \
    done
