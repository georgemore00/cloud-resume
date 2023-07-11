# DynamoDB Table for page visits
resource "aws_dynamodb_table" "db" {
  name         = "pageVisits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "page_counter"

  attribute {
    name = "page_counter"
    type = "S"
  }
}