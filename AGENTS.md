# Infrastructure Repository Instructions

This repository manages personal domain infrastructure for `lancelacoste.com`.

## Scope

- Manage redirect-domain delegation through Namecheap and redirect delivery through Cloudflare.
- Do not add management of the `lancelacoste.com` primary DNS zone, Proton Mail records, or GitHub Pages without explicit direction.
- Keep the configuration small, data-driven, and suitable for a public portfolio later even though this repository is private initially.

## Safety

- Never commit credentials, resolved 1Password values, `.env` files, Terraform state, or plan files.
- Use `op run --env-file=.env.tpl -- ...` for authenticated Terraform commands.
- Import existing live infrastructure before applying changes to resources already configured manually.
- Do not use destructive Namecheap DNS overwrite operations; nameserver delegation is the managed registrar responsibility.

## Conventions

- Use `just` for project commands; do not introduce Make or container wrappers.
- Commit `.terraform.lock.hcl` after provider initialization.
- Use Conventional Commits.
