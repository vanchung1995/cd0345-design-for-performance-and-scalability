# TODO: Define the output variable for the lambda function.
output "api_url" {
  value = aws_apigatewayv2_api.serverless_api.api_endpoint
}
