# Personal Infrastructure Repository Instructions

This repository manages Lance Lacoste's personal infrastructure. Domain routing
for `lancelacoste.com` is the initial managed workload, not the limit of scope.

## Scope

- Organize configuration by infrastructure responsibility and provider as new personal services are added.
- DNS for all owned domains is hosted at Cloudflare; Namecheap is registrar only; DigitalOcean is app hosting only. Do not split DNS across providers.
- Do not add management of the GitHub Pages repository configuration itself without explicit direction.
- Keep the configuration small, data-driven, and suitable for a public portfolio.

## Safety

- Never commit credentials, resolved 1Password values, `.env` files, Terraform state, or plan files.
- Generate the ignored `.env` file from `.env.tpl` using `just env`; it is passed into the Terraform container.
- Import existing live infrastructure before applying changes to resources already configured manually.
- Do not use destructive Namecheap DNS overwrite operations; nameserver delegation is the managed registrar responsibility.

## Conventions

- Use `just` and the repository Docker image for Terraform commands; do not introduce Make.
- Commit `.terraform.lock.hcl` after provider initialization.
- Use Conventional Commits.
