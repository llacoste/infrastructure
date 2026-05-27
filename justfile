set dotenv-load := false
set shell := ["bash", "-uc"]

root := justfile_directory()
image := "lancelacoste-infrastructure"
terraform_version := `awk '/^terraform / {print $2}' .tool-versions`
tflint_version := `awk '/^tflint / {print $2}' .tool-versions`
docker := "docker run --rm --workdir /workdir -v " + root + ":/workdir"
terraform := docker + " " + image + " terraform"
terraform_env := docker + " --env-file .env " + image + " terraform"

default:
    @just --list

env:
    op inject --force -i .env.tpl -o .env

build:
    docker build \
      --build-arg TERRAFORM_VERSION={{terraform_version}} \
      --build-arg TFLINT_VERSION={{tflint_version}} \
      --tag {{image}} .

run: env build
    {{docker}} --interactive --tty --env-file .env {{image}}

fmt: build
    {{terraform}} fmt -recursive

fmt-check: build
    {{terraform}} fmt -check -recursive

init: build
    {{terraform}} init

validate: init
    {{terraform}} validate

lint: build
    {{docker}} {{image}} tflint --recursive

plan: env init
    {{terraform_env}} plan -out=.terraform/plan

apply: env build
    {{terraform_env}} apply .terraform/plan

check-redirects:
    @for domain in llacoste.dev lancelacoste.dev llacoste.com; do \
      printf '%s\n' "https://$domain"; \
      curl --fail --silent --show-error --head "https://$domain"; \
      printf '%s\n' "https://www.$domain"; \
      curl --fail --silent --show-error --head "https://www.$domain"; \
    done
