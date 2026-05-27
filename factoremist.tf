resource "cloudflare_zone" "factoremist" {
  account = {
    id = one(data.cloudflare_accounts.current.result).id
  }

  name = "factoremist.com"
  type = "full"
}

resource "cloudflare_dns_record" "factoremist_apex_a" {
  for_each = toset([
    "162.159.140.98",
    "172.66.0.96",
  ])

  zone_id = cloudflare_zone.factoremist.id
  name    = "factoremist.com"
  type    = "A"
  content = each.value
  ttl     = 30
  proxied = false
  comment = "DigitalOcean App Platform ingress for the factoremist app."
}

resource "cloudflare_dns_record" "factoremist_apex_aaaa" {
  for_each = toset([
    "2a06:98c1:58::60",
    "2606:4700:7::60",
  ])

  zone_id = cloudflare_zone.factoremist.id
  name    = "factoremist.com"
  type    = "AAAA"
  content = each.value
  ttl     = 30
  proxied = false
  comment = "DigitalOcean App Platform ingress for the factoremist app."
}

# Kept while NS propagation completes; removed in a follow-up PR once
# Cloudflare is authoritative for resolvers.
resource "digitalocean_domain" "factoremist" {
  name = "factoremist.com"
}

resource "digitalocean_record" "factoremist_apex_a" {
  for_each = toset([
    "162.159.140.98",
    "172.66.0.96",
  ])

  domain = digitalocean_domain.factoremist.id
  type   = "A"
  name   = "@"
  value  = each.value
  ttl    = 30
}

resource "digitalocean_record" "factoremist_apex_aaaa" {
  for_each = toset([
    "2a06:98c1:58::60",
    "2606:4700:7::60",
  ])

  domain = digitalocean_domain.factoremist.id
  type   = "AAAA"
  name   = "@"
  value  = each.value
  ttl    = 30
}

resource "namecheap_domain_records" "factoremist" {
  domain      = "factoremist.com"
  mode        = "MERGE"
  nameservers = cloudflare_zone.factoremist.name_servers
}

resource "digitalocean_app" "factoremist" {
  spec {
    name   = "factoremist"
    region = "sfo"

    static_site {
      name             = "factoremist"
      source_dir       = "/"
      environment_slug = "html"

      github {
        repo           = "llacoste/factoremist"
        branch         = "master"
        deploy_on_push = true
      }
    }

    domain {
      name = "factoremist.com"
      type = "PRIMARY"
    }

    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    alert {
      rule = "DOMAIN_FAILED"
    }

    ingress {
      rule {
        match {
          path {
            prefix = "/"
          }
        }
        component {
          name = "factoremist"
        }
      }
    }

    features = ["buildpack-stack=ubuntu-22"]
  }
}
