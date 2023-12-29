output "api_endpoint" {
  description = "API Endpoint"
  value       = aws_apigatewayv2_api.websocket_api.api_endpoint
}
