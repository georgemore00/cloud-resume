# Lambda function for retrieving page visitors
resource "aws_lambda_function" "get_visitors_lambda" {
  filename      = "../backend/output/get_page_visits.zip"
  function_name = "GetPageVisitsLambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "get_page_visits.lambda_handler"

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
