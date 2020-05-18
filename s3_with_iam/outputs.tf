output "s3_bucket_name" {
  value = aws_s3_bucket.s3.bucket
}

output "s3_bucket_domain" {
  value = aws_s3_bucket.s3.bucket_regional_domain_name
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.s3.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.s3.id
}

output "iam_user" {
  value = aws_iam_user.iam_user_for_bucket.name
}
