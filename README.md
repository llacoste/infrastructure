# infrastructure

Terraform configuration for personal infrastructure owned and operated by
Lance Lacoste.

## Architecture

The initial managed workload is domain routing for
[lancelacoste.com](https://lancelacoste.com). Namecheap remains the registrar.
Cloudflare provides authoritative DNS, TLS termination, and permanent redirects
for alternate domains:

| Domain | Destination |
| --- | --- |
| `llacoste.dev` | `https://lancelacoste.com/` |
| `lancelacoste.dev` | `https://lancelacoste.com/` |
| `llacoste.com` | `https://lancelacoste.com/` |

Current resources:

- Cloudflare zones for redirect domains.
- Proxied apex and `www` records required for edge redirects.
- Cloudflare `301` redirect rules to the canonical website.
- Namecheap nameserver delegation to Cloudflare.

Additional personal infrastructure can be added here as it is brought under
Terraform management. The primary `lancelacoste.com` DNS zone, email records,
and GitHub Pages website repository are not managed yet.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [just](https://github.com/casey/just)
- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)
- Namecheap API access enabled for the registered redirect domains.
- A Cloudflare API token able to create and manage the redirect zones.

Terraform runs inside the repository's Docker image and is pinned in
`.tool-versions` and `Dockerfile`.

The Cloudflare API token needs these permissions and must cover all zones in
the account because Terraform creates new zones:

| Permission |
| --- |
| `Account / Account Settings / Read` |
| `Zone / Zone / Edit` |
| `Zone / DNS / Edit` |
| `Zone / Single Redirect / Edit` |

The Namecheap provider uses the registered username and API key stored in
1Password. The Cloudflare token must expose a single account; Terraform
discovers that account when creating zones.

## Authentication

Credentials are referenced in `.env.tpl` and materialized into an ignored
`.env` file for Docker:

```dotenv
CLOUDFLARE_API_TOKEN="op://Automation and Tools/Cloudflare Token/api_token"
NAMECHEAP_USER_NAME="op://Automation and Tools/Namecheap/user_name"
NAMECHEAP_API_KEY="op://Automation and Tools/Namecheap/api_key"
NAMECHEAP_USE_SANDBOX="false"
```

Generate local credentials after signing into the 1Password CLI:

```bash
just env
```

## Commands

```bash
just env
just build
just run
just fmt
just init
just validate
just lint
just plan
just apply
just check-redirects
```

`just run` starts an interactive shell in the Terraform container with the
generated `.env` loaded. `just plan` writes the reviewed plan into
`.terraform/plan`; `just apply` applies that exact plan.

## Import Existing Infrastructure

`llacoste.dev` is already live in Cloudflare and already delegated from
Namecheap. Import its existing resources before the first apply. Do not allow
Terraform to attempt to recreate or replace live redirect configuration
without first reviewing the plan.

At minimum, import:

```bash
just run
terraform import 'cloudflare_zone.redirect["llacoste.dev"]' '<cloudflare-zone-id>'

terraform import 'namecheap_domain_records.delegation["llacoste.dev"]' 'llacoste.dev'
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
