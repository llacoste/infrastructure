# infrastructure

Declarative Terraform configuration for the personal infrastructure that Lance
Lacoste owns and operates — domains, accounts, services, and anything else
worth keeping under version control.

Currently managed: DNS and HTTPS redirects for the alternate personal domains
pointing at [lancelacoste.com](https://lancelacoste.com). Not yet managed: the
primary `lancelacoste.com` zone, Proton Mail records, and the GitHub Pages
website repository.

## Setup

Required tools:

- [Docker](https://docs.docker.com/get-docker/)
- [just](https://github.com/casey/just)
- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)

Terraform itself runs inside the repository's Docker image and is pinned in
`.tool-versions`. No local Terraform install is required.

Credentials live in the `Automation and Tools` 1Password vault and are
referenced from `.env.tpl`. After signing in to the 1Password CLI, generate
the ignored `.env` file that the Terraform container consumes:

```bash
just env
```

Re-run `just env` whenever the underlying 1Password items change. The file is
gitignored and is passed to the container via `--env-file .env`; resolved
secrets are never written to logs or committed.

### Cloudflare token

The Cloudflare API token must cover all zones in the account, because
Terraform creates new zones. It needs `Account Settings / Read` so the
configuration can discover the account ID without it being supplied manually,
and `Account / Zone / Edit` so Terraform can create zones inside the account
(the zone-level `Zone / Zone / Edit` permission only covers *modifying*
existing zones).

| Permission |
| --- |
| `Account / Account Settings / Read` |
| `Account / Zone / Edit` |
| `Zone / Zone / Edit` |
| `Zone / DNS / Edit` |
| `Zone / Single Redirect / Edit` |

Account Resources should be set to `Include — All accounts`. Zone Resources
should cover every zone Terraform will manage.

### Namecheap API

Namecheap's API is opt-in and IP-restricted. In your Namecheap account at
`ap.www.namecheap.com/settings/tools/apiaccess/`:

- Turn on **API Access**.
- Add every IP you'll run Terraform from to **Whitelisted IPs** (your home
  network, any laptop's current address, CI runners if/when applicable).

A request from an unlisted IP returns `Invalid request IP (1011150)` and
every Namecheap-touching Terraform operation will fail with that error until
the IP is added.

### DigitalOcean token

Create a Personal Access Token at
`https://cloud.digitalocean.com/account/api/tokens` scoped to read + write
for at least the `Domain` resource. Store it in 1Password as a new item
named `DigitalOcean` in the `Automation and Tools` vault with a field
`api_token` — the `.env.tpl` reference points at that exact path.

## Running

Day-to-day commands:

```bash
just fmt              # format all .tf files
just validate         # static schema check
just lint             # tflint with the recommended ruleset
just plan             # write a reviewed plan to .terraform/plan
just apply            # apply the reviewed plan
just run              # interactive shell in the Terraform container
just check-redirects  # smoke-test the redirect domains
```

`just plan` writes its output to `.terraform/plan` so `just apply` runs the
exact plan that was reviewed.

CI surfaces three separate status checks on every push and pull request —
`CI / fmt`, `CI / validate`, `CI / lint` — plus a weekly `Versions` job that
fails when the Terraform or TFLint pins in `.tool-versions` fall behind
upstream. Dependabot opens weekly PRs for Terraform providers, GitHub Actions
pins, and the Docker base image.

## State

Terraform state is local and gitignored. Configure a remote, encrypted state
backend before the first production apply if this repository will be used
from multiple machines or automation.
