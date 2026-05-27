resource "digitalocean_domain" "threadscape_art" {
  name = "threadscape.art"
}

resource "digitalocean_record" "threadscape_art_apex_a" {
  for_each = toset([
    "162.159.140.98",
    "172.66.0.96",
  ])

  domain = digitalocean_domain.threadscape_art.id
  type   = "A"
  name   = "@"
  value  = each.value
  ttl    = 30
}

resource "digitalocean_record" "threadscape_art_apex_aaaa" {
  for_each = toset([
    "2a06:98c1:58::60",
    "2606:4700:7::60",
  ])

  domain = digitalocean_domain.threadscape_art.id
  type   = "AAAA"
  name   = "@"
  value  = each.value
  ttl    = 30
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
      name = "threadscape.art"
      type = "PRIMARY"
      zone = "threadscape.art"
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
