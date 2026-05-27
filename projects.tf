resource "digitalocean_project" "factoremist" {
  name        = "factoremist"
  description = "My Business Website"
  purpose     = "Website or blog"
  resources = [
    digitalocean_domain.factoremist.urn,
    digitalocean_app.factoremist.urn,
  ]
}

resource "digitalocean_project" "polypaige_kiosk" {
  name        = "PolyPaige_Kiosk"
  description = ""
  purpose     = "Website or blog"
  resources = [
    digitalocean_app.polypaige_kiosk.urn,
  ]
}

resource "digitalocean_project" "threadscape" {
  name        = "threadscape"
  description = ""
  purpose     = "Web Application"
  is_default  = true
  resources = [
    digitalocean_domain.threadscape_art.urn,
    digitalocean_app.threadscape.urn,
  ]
}
