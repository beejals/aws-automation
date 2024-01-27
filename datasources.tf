data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_role_assume_role_policy" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_role_create_logs_policy" {
  statement {
    sid = ""

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "lambda_role_tag_ec2_policy" {
  statement {
    sid = ""

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = [
      "*",
    ]
  }
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/python312.zip"
}

data "aws_iam_policy_document" "cloudtrail_role_assume_role_policy" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_role_create_logs_policy" {
  statement {
    sid = ""

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}