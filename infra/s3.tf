# S3 bucket for resume website
resource "aws_s3_bucket" "resume_website_bucket" {
  bucket = "george-more-resume"
}

# S3 bucket enable public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.resume_website_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = false
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
