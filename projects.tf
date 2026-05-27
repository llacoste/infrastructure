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
    digitalocean_app.threadscape.urn,
  ]

  # The DO API has no way to remove a URN from a project once its underlying
  # resource is deleted; the threadscape.art domain URN lingers after that
  # zone was destroyed. Ignoring drift on resources here avoids permanent
  # phantom diffs on plan/apply.
  lifecycle {
    ignore_changes = [resources]
  }
}
