locals {
  canonical_url = "https://lancelacoste.com/"

  redirect_domains = toset([
    "llacoste.dev",
    "lancelacoste.dev",
    "llacoste.com",
  ])
}
