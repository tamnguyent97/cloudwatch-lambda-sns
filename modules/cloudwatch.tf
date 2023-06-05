data "aws_cloudwatch_log_group" "example" {
  name = var.name_aws_cloudwatch_log_group
}

resource "aws_cloudwatch_log_subscription_filter" "name" {
  log_group_name  = data.aws_cloudwatch_log_group.example.name
  name            = "${data.aws_cloudwatch_log_group.example.name}-subscription-filter"
  destination_arn = aws_lambda_function.example.arn
  filter_pattern  = var.filter_pattern
  depends_on      = [aws_lambda_permission.logging]
}

resource "aws_lambda_permission" "logging" {
  statement_id = "CWLSubscriptionFilter"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "${data.aws_cloudwatch_log_group.example.arn}:*"
  source_account = data.aws_caller_identity.current.account_id
}