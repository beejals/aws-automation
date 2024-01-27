# create iam role for our lambda function
resource "aws_iam_role" "tag_ec2_instance_lambda_role" {
  name               = "Tag_Ec2_Instance_Lamda_Function_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.create_logs_lambda_policy.arn,
    aws_iam_policy.tag_ec2_instance_lambda_policy.arn
  ]
}

# create iam policy for our lambda function to create tags
resource "aws_iam_policy" "create_logs_lambda_policy" {
  name        = "create_logs_lambda_policy"
  path        = "/"
  description = "Policy to allow creation of logs"
  policy      = data.aws_iam_policy_document.lambda_role_create_logs_policy.json
}

# create iam policy for our lambda function to create tags
resource "aws_iam_policy" "tag_ec2_instance_lambda_policy" {
  name        = "tag_ec2_instance_lambda_policy"
  path        = "/"
  description = "Policy to allow tagging of ec2 instances"
  policy      = data.aws_iam_policy_document.lambda_role_tag_ec2_policy.json
}

# create lambda function that will tag EC2 instances
resource "aws_lambda_function" "tag_ec2_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/python/python312.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.tag_ec2_instance_lambda_role.arn
  handler          = "${var.lambda_function_name}.lambda_handler"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha512
  runtime          = "python3.12"
  depends_on       = [aws_iam_role.tag_ec2_instance_lambda_role]
}

resource "aws_cloudwatch_log_group" "tag_ec2_lambda_function_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}

# Create the S3 bucket
resource "aws_s3_bucket" "cloudwatch_logging_bucket" {
  bucket        = "cloudwatch-logging-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudwatch_s3_bucket_policy" {
  bucket = aws_s3_bucket.cloudwatch_logging_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# create iam role to send CloudTrail events to the CloudWatch Logs log group
resource "aws_iam_role" "cloudtrail_CloudWatch_log_role" {
  name               = "cloudtrail_CloudWatch_log_role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_role_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.create_logs_cloudtrail_policy.arn
  ]
}

resource "aws_iam_policy" "create_logs_cloudtrail_policy" {
  name        = "create_logs_cloudtrail_policy"
  path        = "/"
  description = "Policy to allow creation of logs"
  policy      = data.aws_iam_policy_document.cloudtrail_role_create_logs_policy.json
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/cloudtrail/logs"
  retention_in_days = 1
}

resource "aws_cloudtrail" "ec2_instance_api_trail" {
  depends_on = [aws_s3_bucket_policy.cloudwatch_s3_bucket_policy]

  name                          = "ec2_instance_api_trail"
  s3_bucket_name                = aws_s3_bucket.cloudwatch_logging_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_CloudWatch_log_role.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}:*"
}

resource "aws_cloudwatch_event_rule" "ec2-launch" {
  name        = "capture-ec2-instance-launch"
  description = "Capture each EC2 Instance Launch"

  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["RunInstances"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "tag_ec2_lambda" {
  rule      = aws_cloudwatch_event_rule.ec2-launch.name
  target_id = aws_lambda_function.tag_ec2_lambda.id
  arn       = aws_lambda_function.tag_ec2_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_tag_ec2_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tag_ec2_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2-launch.arn
}
