resource "cloudflare_dns_record" "threadscape_subdomain" {
  zone_id = cloudflare_zone.redirect["llacoste.dev"].id
  name    = "threadscape.llacoste.dev"
  type    = "CNAME"
  content = "threadscape-9c7zm.ondigitalocean.app"
  ttl     = 60
  proxied = false
  comment = "DigitalOcean App Platform ingress for the threadscape app."
}

resource "digitalocean_app" "threadscape" {
  spec {
    name   = "threadscape"
    region = "nyc"

    static_site {
      name             = "threadscape"
      source_dir       = "/"
      environment_slug = "html"

      github {
        repo           = "llacoste/threadscape"
        branch         = "master"
        deploy_on_push = true
      }
    }

    domain {
      name = "threadscape.llacoste.dev"
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
          name = "threadscape"
        }
      }
    }

    features = ["buildpack-stack=ubuntu-22"]
  }
}
