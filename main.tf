locals {
  name_aws_cloudwatch_log_group = "/aws/lambda/ex2-function"
  topicName                     = "Topic1"
  filter_pattern                = ""
}

module "cwl-lambda-sns" {
  source = "./modules/"

  name_aws_cloudwatch_log_group = local.name_aws_cloudwatch_log_group
  topicName                     = local.topicName
  filter_pattern                = local.filter_pattern
}