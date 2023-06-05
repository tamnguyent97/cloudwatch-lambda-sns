data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "publish_sns" {
  statement {
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${data.aws_sns_topic.name.name}",
    ]
  }
}

data "aws_iam_policy_document" "lambda_basic_execution_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_cloudwatch_log_group.example.name}",
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${terraform.workspace}-Lambda-Send-Mail-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "lambda_execution" {
  name   = "Lambda-Basic-Execution-Policy"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.lambda_basic_execution_role_policy.json
}

resource "aws_iam_role_policy" "lambda_sns_execution" {
  name   = "Lambda-SNS-Execution-Policy"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.publish_sns.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/logMailer.py"
  output_path = "${path.module}/logMailer.zip"
}

resource "aws_lambda_function" "example" {
  filename      = data.archive_file.lambda.output_path
  function_name = "${terraform.workspace}-Send-Email"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "logMailer.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"
  depends_on = [
    data.archive_file.lambda
  ]
  
  environment {
    variables = {
      SNS_TOPIC_ARN = "${data.aws_sns_topic.name.arn}"
    }
  }
}

resource "aws_cloudwatch_log_group" "cwl_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.example.function_name}"
  retention_in_days = 5
  depends_on = [ aws_lambda_function.example ]
}