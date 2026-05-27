resource "namecheap_domain_records" "delegation" {
  for_each = local.redirect_domains

  domain      = each.value
  mode        = "MERGE"
  nameservers = cloudflare_zone.redirect[each.key].name_servers
}
