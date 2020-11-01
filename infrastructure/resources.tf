provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "b" {
  bucket_prefix = "trnka-dvc-"
  acl = "private"
}

resource "aws_iam_user" "dvc_user" {
  name = "github_actions_dvc"
  force_destroy = true
}

resource "aws_iam_user_policy" "dvc_policy" {
  name = "dvc_policy"
  user = aws_iam_user.dvc_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.b.bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.b.bucket}/*"]
    }
  ]
}

EOF
}

resource "aws_iam_access_key" "dvc_user" {
  user = aws_iam_user.dvc_user.name
}

output "secret" {
  value = aws_iam_access_key.dvc_user.secret
}