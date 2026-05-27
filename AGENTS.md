# Personal Infrastructure Repository Instructions

This repository manages Lance Lacoste's personal infrastructure. Domain routing
for `lancelacoste.com` is the initial managed workload, not the limit of scope.

## Scope

- Organize configuration by infrastructure responsibility and provider as new personal services are added.
- Manage redirect-domain delegation through Namecheap and redirect delivery through Cloudflare as the initial workload.
- Do not add management of the `lancelacoste.com` primary DNS zone, Proton Mail records, or GitHub Pages without explicit direction.
- Keep the configuration small, data-driven, and suitable for a public portfolio later even though this repository is private initially.

## Safety

- Never commit credentials, resolved 1Password values, `.env` files, Terraform state, or plan files.
- Generate the ignored `.env` file from `.env.tpl` using `just env`; it is passed into the Terraform container.
- Import existing live infrastructure before applying changes to resources already configured manually.
- Do not use destructive Namecheap DNS overwrite operations; nameserver delegation is the managed registrar responsibility.

## Conventions

- Use `just` and the repository Docker image for Terraform commands; do not introduce Make.
- Commit `.terraform.lock.hcl` after provider initialization.
- Use Conventional Commits.
