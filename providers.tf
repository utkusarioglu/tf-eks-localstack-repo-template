provider "aws" {
  region  = var.cluster_region
  profile = var.aws_profile

  s3_use_path_style           = true
  access_key                  = "localstack"
  secret_key                  = "localstack"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = var.aws_provider_default_tags
  }

  endpoints {
    apigateway       = var.localstack_endpoint
    autoscaling      = var.localstack_endpoint
    autoscalingplans = var.localstack_endpoint
    cloudformation   = var.localstack_endpoint
    elbv2            = var.localstack_endpoint
    cloudwatch       = var.localstack_endpoint
    dynamodb         = var.localstack_endpoint
    ec2              = var.localstack_endpoint
    acm              = var.localstack_endpoint
    cloudwatchlogs   = var.localstack_endpoint
    eks              = var.localstack_endpoint
    es               = var.localstack_endpoint
    firehose         = var.localstack_endpoint
    iam              = var.localstack_endpoint
    kinesis          = var.localstack_endpoint
    lambda           = var.localstack_endpoint
    redshift         = var.localstack_endpoint
    route53          = var.localstack_endpoint
    route53resolver  = var.localstack_endpoint
    route53domains   = var.localstack_endpoint
    s3               = var.localstack_endpoint
    secretsmanager   = var.localstack_endpoint
    ses              = var.localstack_endpoint
    sns              = var.localstack_endpoint
    sqs              = var.localstack_endpoint
    ssm              = var.localstack_endpoint
    stepfunctions    = var.localstack_endpoint
    sts              = var.localstack_endpoint
  }
}
