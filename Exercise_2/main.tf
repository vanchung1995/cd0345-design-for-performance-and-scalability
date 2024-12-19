provider "aws" {
  region                  = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                 = "default"
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy allow Lambda to log to CloudwatchLog
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "serverless_function" {
  function_name = "serverless_function"
  runtime       = "python3.9" 
  handler       = "greet_lambda.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn

  filename = "greet_lambda.zip"

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      greeting = "Hello"
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "serverless_api" {
  name          = "serverless-api"
  protocol_type = "HTTP"
}

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.serverless_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.serverless_function.invoke_arn
  payload_format_version = "2.0"
}

# API Gateway Route
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.serverless_api.id
  route_key = "GET /greeting"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Deployment
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.serverless_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.serverless_api.execution_arn}/*/*"
}
