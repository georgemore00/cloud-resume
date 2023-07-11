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

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_visitors_lambda.invoke_arn
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
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.rest-api.id
  api_resource_id = aws_api_gateway_resource.visitors-resource.id
}