# ACM/TLS certificate for HTTPS
resource "aws_acm_certificate" "resume-website-ssl" {
  domain_name       = var.website-domain
  validation_method = "DNS"
}