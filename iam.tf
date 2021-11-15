resource "aws_iam_instance_profile" "mcserver" {
  name = "mcserver_profile"
  role = aws_iam_role.mcserver.name
}

resource "aws_iam_role" "mcserver" {
  name = "mcserver"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "mcserver" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.mcserver.arn}/*",
      aws_s3_bucket.mcserver.arn,
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "mcserver" {
  name   = "mcserver-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.mcserver.json
}

resource "aws_iam_policy_attachment" "mcserver" {
  name       = "mcserver"
  roles      = [aws_iam_role.mcserver.name]
  policy_arn = aws_iam_policy.mcserver.arn
}
