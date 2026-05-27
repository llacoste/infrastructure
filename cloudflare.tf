data "cloudflare_accounts" "current" {
  max_items = 2
}

resource "cloudflare_zone" "redirect" {
  for_each = local.redirect_domains

  account = {
    id = one(data.cloudflare_accounts.current.result).id
  }

  name = each.value
  type = "full"
}

# Redirect Rules run at Cloudflare's edge; these proxied records provide the
# routed hostnames needed to receive HTTP and HTTPS requests.
resource "cloudflare_dns_record" "apex" {
  for_each = local.redirect_domains

  zone_id = cloudflare_zone.redirect[each.key].id
  name    = each.value
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
  comment = "Edge redirect to lancelacoste.com; no origin traffic expected."
}

resource "cloudflare_dns_record" "www" {
  for_each = local.redirect_domains

  zone_id = cloudflare_zone.redirect[each.key].id
  name    = "www.${each.value}"
  type    = "CNAME"
  content = each.value
  ttl     = 1
  proxied = true
  comment = "Edge redirect to lancelacoste.com; no origin traffic expected."
}
