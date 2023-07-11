# CloudFront distribution for the website
resource "aws_cloudfront_distribution" "website_distribution" {

  aliases = [var.website-domain]

  origin {
    domain_name = aws_s3_bucket.resume_website_bucket.website_endpoint
    origin_id   = "S3Origin"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]

    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.resume-website-ssl.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}