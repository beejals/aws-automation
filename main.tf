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
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/python/python312.zip"
  function_name    = "TagEc2Instance"
  role             = aws_iam_role.tag_ec2_instance_lambda_role.arn
  handler          = "TagEc2Instance.lambda_handler"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha512
  runtime          = "python3.12"
  depends_on       = [aws_iam_role.tag_ec2_instance_lambda_role]
}