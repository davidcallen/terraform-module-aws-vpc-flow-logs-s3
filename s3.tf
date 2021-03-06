# ---------------------------------------------------------------------------------------------------------------------
# S3 storage for VPC Flow Logs (long-term storage)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "vpc-flow-logs" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  lifecycle {
    prevent_destroy = true # cant use variable here for resource_deletion_protection :(
  }
  tags = merge(var.tags, {
    Name        = var.s3_bucket_name
    Description = "Contains VPC Flow Logs. These Logs also in Cloudwatch but in S3 held for longer rentention period for cost saving."
  })
}
resource "aws_s3_bucket_versioning" "vpc-flow-logs" {
  bucket = aws_s3_bucket.vpc-flow-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc-flow-logs" {
  bucket = aws_s3_bucket.vpc-flow-logs.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "vpc-flow-logs" {
  bucket = aws_s3_bucket.vpc-flow-logs.bucket
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Sid": "1",
          "Action": "s3:GetBucketAcl",
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}",
          "Principal": {
            "Service": "logs.${var.aws_region}.amazonaws.com"
          }
      },
      {
          "Sid": "2",
          "Action": "s3:PutObject" ,
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
          "Condition": {
            "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" }
          },
          "Principal": {
            "Service": "logs.${var.aws_region}.amazonaws.com"
          }
      },
      {
          "Sid": "AWSLogDeliveryWrite",
          "Effect": "Allow",
          "Principal": {
              "Service": "delivery.logs.amazonaws.com"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}/AWSLogs/${var.account_id}/*",
          "Condition": {
              "StringEquals": {
                  "s3:x-amz-acl": "bucket-owner-full-control"
              }
          }
      },
      {
          "Sid": "AWSLogDeliveryAclCheck",
          "Effect": "Allow",
          "Principal": {
              "Service": "delivery.logs.amazonaws.com"
          },
          "Action": "s3:GetBucketAcl",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
      }
    ]
}
EOF
}
resource "aws_s3_bucket_lifecycle_configuration" "vpc-flow-logs" {
  bucket = aws_s3_bucket.vpc-flow-logs.bucket
  rule {
    id     = "Ageing"
    status = "Enabled"
    filter {
      prefix = "*"
    }
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 360
    }
  }
}
data "aws_canonical_user_id" "current_user" {}
