# infrastructure

Terraform configuration for personal domain routing to
[lancelacoste.com](https://lancelacoste.com).

## Architecture

Namecheap remains the registrar. Cloudflare provides authoritative DNS,
TLS termination, and permanent redirects for alternate domains:

| Domain | Destination |
| --- | --- |
| `llacoste.dev` | `https://lancelacoste.com/` |
| `lancelacoste.dev` | `https://lancelacoste.com/` |
| `llacoste.com` | `https://lancelacoste.com/` |

This repository manages:

- Cloudflare zones for redirect domains.
- Proxied apex and `www` records required for edge redirects.
- Cloudflare `301` redirect rules to the canonical website.
- Namecheap nameserver delegation to Cloudflare.

It does not manage the primary `lancelacoste.com` DNS zone, email records, or
the GitHub Pages website repository.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5`
- [just](https://github.com/casey/just)
- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)
- Namecheap API access enabled for the registered redirect domains.
- A Cloudflare API token able to create and manage the redirect zones.

The Cloudflare API token needs these permissions and must cover all zones in
the account because Terraform creates new zones:

| Permission |
| --- |
| `Zone / Zone / Edit` |
| `Zone / DNS / Edit` |
| `Zone / Single Redirect / Edit` |

The Namecheap provider uses the registered username and API key stored in
1Password.

## Authentication

Credentials are referenced in `.env.tpl` and resolved only for the lifetime of
each command through `op run`:

```dotenv
CLOUDFLARE_API_TOKEN="op://Automation and Tools/Cloudflare Token/api_token"
NAMECHEAP_USER_NAME="op://Automation and Tools/Namecheap/user_name"
NAMECHEAP_API_KEY="op://Automation and Tools/Namecheap/api_key"
NAMECHEAP_USE_SANDBOX="false"
```

No generated `.env` file is required. Local `.env` files and Terraform state
are gitignored.

Copy `terraform.tfvars.example` to `terraform.tfvars` and supply the
Cloudflare account ID before planning:

```bash
cp terraform.tfvars.example terraform.tfvars
```

The account ID is not a secret, but `terraform.tfvars` is intentionally kept
local until the repository configuration is established.

## Commands

```bash
just fmt
just init
just validate
just plan
just apply
just check-redirects
```

`just plan` writes the reviewed plan into `.terraform/plan`; `just apply`
applies that exact plan.

## Import Existing Infrastructure

`llacoste.dev` is already live in Cloudflare and already delegated from
Namecheap. Import its existing resources before the first apply. Do not allow
Terraform to attempt to recreate or replace live redirect configuration
without first reviewing the plan.

At minimum, import:

```bash
op run --env-file=.env.tpl -- terraform import \
  'cloudflare_zone.redirect["llacoste.dev"]' '<cloudflare-zone-id>'

op run --env-file=.env.tpl -- terraform import \
  'namecheap_domain_records.delegation["llacoste.dev"]' 'llacoste.dev'
```

The existing Cloudflare apex record, `www` record, and redirect ruleset must
also be imported or consciously replaced after comparing the Terraform plan
with the active Cloudflare configuration.

For `lancelacoste.dev` and `llacoste.com`, Terraform will create the Cloudflare
zones and then delegate their Namecheap nameservers to the assigned
Cloudflare nameservers.

## State

Terraform state is currently local and ignored by Git. Configure a remote,
encrypted state backend before the first production apply if this repository
will be used from multiple machines or automation.
