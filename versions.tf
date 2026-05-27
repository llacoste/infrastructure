terraform {
  required_version = "~> 1.15.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.19"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.87"
    }

    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.3"
    }
  }
}
