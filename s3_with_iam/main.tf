resource "aws_s3_bucket" "s3" {
  bucket = "${var.bucket_prefix}${var.bucket_name}"
  acl = "private"
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

resource "aws_s3_bucket_policy" "example" {
  bucket = "${aws_s3_bucket.s3.id}"
  policy = "${data.aws_iam_policy_document.s3_public_access_policy.json}"
}

resource "aws_s3_bucket_object" "s3_dev_content" {
  bucket = "${aws_s3_bucket.s3.bucket}"
  key = "dev/index.html"
  content = "This is Dev"
  content_type = "text/html"
  count = "${var.create_folder ? 1 : 0}"
  lifecycle {
    ignore_changes = ["*"]
  }
}

resource "aws_s3_bucket_object" "s3_test_content" {
  bucket = "${aws_s3_bucket.s3.bucket}"
  key = "test/index.html"
  content = "This is Test"
  content_type = "text/html"
  count = "${var.create_folder ? 1 : 0}"
  lifecycle {
    ignore_changes = ["*"]
  }
}

resource "aws_s3_bucket_object" "s3_sandbox_content" {
  bucket = "${aws_s3_bucket.s3.bucket}"
  key = "sandbox/index.html"
  content = "This is Sandbox"
  content_type = "text/html"
  count = "${var.create_folder ? 1 : 0}"
  lifecycle {
    ignore_changes = ["*"]
  }
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
          "s3:GetObject"
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
  policy_arn = "${aws_iam_policy.bucket_policy.arn}"
  user = "${aws_iam_user.iam_user_for_bucket.name}"
}
