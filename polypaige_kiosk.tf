resource "digitalocean_app" "polypaige_kiosk" {
  spec {
    name   = "polypaige-kiosk"
    region = "nyc"

    static_site {
      name             = "polypaige-kiosk"
      source_dir       = "/"
      environment_slug = "html"

      github {
        repo           = "llacoste/polypaige_kiosk"
        branch         = "master"
        deploy_on_push = true
      }
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
          name = "polypaige-kiosk"
        }
      }
    }

    features = ["buildpack-stack=ubuntu-22"]
  }
}
