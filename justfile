set dotenv-load := false
set shell := ["bash", "-uc"]

root := justfile_directory()
image := "lancelacoste-infrastructure"
terraform_version := `awk '/^terraform / {print $2}' .tool-versions`
tflint_version := `awk '/^tflint / {print $2}' .tool-versions`
just_version := `awk '/^just / {print $2}' .tool-versions`

# When this justfile runs inside the Terraform container, terraform / tflint
# are already on PATH and credentials are mounted via --env-file. Recipes run
# the commands directly instead of wrapping each one in `docker run`, and
# host-only recipes (env, build, run) become no-ops or fail loudly.
in_container := if path_exists("/.dockerenv") == "true" { "1" } else { "" }

docker_run := "docker run --rm --workdir /workdir -v " + root + ":/workdir"
terraform := if in_container == "1" { "terraform" } else { docker_run + " " + image + " terraform" }
terraform_env := if in_container == "1" { "terraform" } else { docker_run + " --env-file .env " + image + " terraform" }
tflint := if in_container == "1" { "tflint" } else { docker_run + " " + image + " tflint" }

default:
    @just --list

env:
    @if [ "{{in_container}}" = "1" ]; then \
      echo "Inside container; .env is mounted via --env-file. Skipping op inject."; \
    else \
      op inject --force -i .env.tpl -o .env; \
    fi

build:
    @if [ "{{in_container}}" = "1" ]; then \
      echo "Inside container; build is a host-side operation. Skipping."; \
    else \
      docker build \
        --build-arg TERRAFORM_VERSION={{terraform_version}} \
        --build-arg TFLINT_VERSION={{tflint_version}} \
        --build-arg JUST_VERSION={{just_version}} \
        --tag {{image}} . ; \
    fi

run: env build
    @if [ "{{in_container}}" = "1" ]; then \
      echo "Already inside the container." >&2; exit 1; \
    fi
    docker run --rm --interactive --tty --workdir /workdir --env-file .env -v {{root}}:/workdir {{image}}

fmt: build
    {{terraform}} fmt -recursive

fmt-check: build
    {{terraform}} fmt -check -recursive

init: build
    {{terraform}} init

validate: init
    {{terraform}} validate

lint: build
    {{tflint}} --recursive

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
