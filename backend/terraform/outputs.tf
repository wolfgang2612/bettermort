output "api_endpoint" {
  description = "API Endpoint"
  value       = aws_apigatewayv2_api.websocket_api.api_endpoint
}

output "api_id" {
  description = "API ID"
  value       = aws_apigatewayv2_api.websocket_api.id
}

output "stage" {
  description = "API Stage"
  value       = aws_apigatewayv2_stage.api_stage.name
}

