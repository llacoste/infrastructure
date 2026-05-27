output "cloudflare_nameservers" {
  description = "Cloudflare-assigned nameservers delegated through Namecheap."
  value = {
    for domain, zone in cloudflare_zone.redirect : domain => zone.name_servers
  }
}

output "redirect_domains" {
  description = "Domains redirected to the canonical website."
  value       = sort(tolist(local.redirect_domains))
}
