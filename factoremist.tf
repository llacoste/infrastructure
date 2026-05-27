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
  domain = "factoremist.com"
  mode   = "MERGE"
  nameservers = [
    "ns1.digitalocean.com",
    "ns2.digitalocean.com",
    "ns3.digitalocean.com",
  ]
}
