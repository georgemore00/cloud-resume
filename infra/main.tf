# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# S3 bucket for resume website
resource "aws_s3_bucket" "resume_website_bucket"{
  bucket = "george-more-resume"
}

# S3 bucket enable public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.resume_website_bucket.bucket

  block_public_acls = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls = false
}

# S3 static website hosting configuration
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.resume_website_bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

# S3 bucket policy to allow public access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.resume_website_bucket.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.resume_website_bucket.arn}",
        "${aws_s3_bucket.resume_website_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

# ACM/TLS certificate for HTTPS
resource "aws_acm_certificate" "resume-website-ssl" {
  domain_name = var.website-domain
  validation_method = "DNS"
}

# CloudFront distribution for the website
resource "aws_cloudfront_distribution" "website_distribution" {

  aliases = [var.website-domain]

  origin {
    domain_name = aws_s3_bucket.resume_website_bucket.website_endpoint
    origin_id = "S3Origin"

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
    ssl_support_method = "sni-only"
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]

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

# DynamoDB Table for page visits
resource "aws_dynamodb_table" "db" {
  name = "pageVisits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "page_counter"

  attribute {
    name = "page_counter"
    type = "S"
  }
}

# Lambda function for retrieving page visitors
resource "aws_lambda_function" "get_visitors_lambda" {
  filename = "../backend/output/get_page_visits.zip"
  function_name = "GetPageVisitsLambda"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "get_page_visits.lambda_handler"

  runtime = "python3.10"
}

# Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaBasicExecutionAndDynamoDB"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach BasicExecutionRole policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach ReadAndWriteItemsToDynamoDB policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::087937754946:policy/ReadAndWriteItemsToDynamoDB"
}

# API Gateway REST API for the Cloud Resume API
resource "aws_api_gateway_rest_api" "rest-api" {
  name = "CloudResumeAPI"
}

# Setup /visitors resource
resource "aws_api_gateway_resource" "visitors-resource" {
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "visitors"
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
}

# Setup GET method for /visitors resource
resource "aws_api_gateway_method" "get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.visitors-resource.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
}

# Setup integration with lambda function for GET method
resource "aws_api_gateway_integration" "lambda_integration" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.visitors-resource.id
  rest_api_id = aws_api_gateway_rest_api.rest-api.id

  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.get_visitors_lambda.invoke_arn
}

# Allow execution from API Gateway to Lambda
resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visitors_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# Setup API Gateway deployment
resource "aws_api_gateway_deployment" "apigw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id

  # Enable redeployment when changing resource, method, or integration
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.visitors-resource.id,
      aws_api_gateway_method.get.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Setup API Gateway prod stage
resource "aws_api_gateway_stage" "apigw_prod_stage" {
  deployment_id = aws_api_gateway_deployment.apigw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  stage_name    = "prod"
}

# Enable CORS for Api Gateway
module "cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.rest-api.id
  api_resource_id = aws_api_gateway_resource.visitors-resource.id
}