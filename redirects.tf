resource "cloudflare_ruleset" "redirect" {
  for_each = local.redirect_domains

  zone_id     = cloudflare_zone.redirect[each.key].id
  name        = "Canonical website redirect"
  description = "Redirect alternate personal domains to lancelacoste.com."
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "redirect_to_canonical_website"
      description = "Redirect all traffic to lancelacoste.com."
      expression  = "(http.host eq \"${each.value}\") or (http.host eq \"www.${each.value}\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            value = local.canonical_url
          }
          preserve_query_string = false
        }
      }
      enabled = true
    }
  ]
}
