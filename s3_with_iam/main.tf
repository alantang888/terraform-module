resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "s3_public_access_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type = "*"
    }
  }
}

resource "aws_s3_bucket_policy" "attach_public_read_to_s3" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_public_access_policy.json
}

resource "aws_iam_policy" "bucket_policy" {
  name = "s3-${var.bucket_name}-full"
  path = "/"
  description = "Policy for read write access to S3 ${aws_s3_bucket.s3.bucket} bucket"
  // the first { must at beggin of line. otherwise will have "invalid JSON policy" error.
  // ref: https://github.com/terraform-providers/terraform-provider-aws/issues/1873
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:ListAllMyBuckets",
        "Resource": "arn:aws:s3:::*"
      },
      {
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.s3.bucket}"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*"
      }
    ]
  }
  EOF
}

resource "aws_iam_user" "iam_user_for_bucket" {
  name = "s3-${var.bucket_name}-full"

}

resource "aws_iam_user_policy_attachment" "bind_policy_to_user" {
  policy_arn = aws_iam_policy.bucket_policy.arn
  user = aws_iam_user.iam_user_for_bucket.name
}
