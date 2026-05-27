resource "cloudflare_zone" "lancelacoste" {
  account = {
    id = one(data.cloudflare_accounts.current.result).id
  }

  name = "lancelacoste.com"
  type = "full"
}

resource "cloudflare_dns_record" "lancelacoste_apex_a" {
  for_each = toset([
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ])

  zone_id = cloudflare_zone.lancelacoste.id
  name    = "lancelacoste.com"
  type    = "A"
  content = each.value
  ttl     = 60
  proxied = false
  comment = "GitHub Pages ingress for the lancelacoste.com website."
}

resource "cloudflare_dns_record" "lancelacoste_www" {
  zone_id = cloudflare_zone.lancelacoste.id
  name    = "www.lancelacoste.com"
  type    = "CNAME"
  content = "llacoste.github.io"
  ttl     = 60
  proxied = false
  comment = "GitHub Pages CNAME for the www subdomain."
}

resource "cloudflare_dns_record" "lancelacoste_mx" {
  for_each = {
    "eforward1.registrar-servers.com" = 10
    "eforward2.registrar-servers.com" = 10
    "eforward3.registrar-servers.com" = 10
    "eforward4.registrar-servers.com" = 15
    "eforward5.registrar-servers.com" = 20
  }

  zone_id  = cloudflare_zone.lancelacoste.id
  name     = "lancelacoste.com"
  type     = "MX"
  content  = each.key
  priority = each.value
  ttl      = 60
  proxied  = false
  comment  = "Namecheap email forwarding for lancelacoste.com mailboxes."
}

resource "cloudflare_dns_record" "lancelacoste_spf" {
  zone_id = cloudflare_zone.lancelacoste.id
  name    = "lancelacoste.com"
  type    = "TXT"
  content = "v=spf1 include:spf.efwd.registrar-servers.com ~all"
  ttl     = 60
  proxied = false
  comment = "SPF authorizing Namecheap email forwarding to send on behalf of the domain."
}

resource "namecheap_domain_records" "lancelacoste" {
  domain      = "lancelacoste.com"
  mode        = "MERGE"
  nameservers = cloudflare_zone.lancelacoste.name_servers
}
