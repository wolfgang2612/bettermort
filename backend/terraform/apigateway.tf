resource "aws_api_gateway_account" "apigateway_account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "bettermort"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id        = aws_apigatewayv2_api.websocket_api.id
  name          = "prod"
  deployment_id = aws_apigatewayv2_deployment.deployment.id

  default_route_settings {
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }
}

resource "aws_apigatewayv2_integration" "integration" {
  count            = length(var.websocket_routes)
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.websocket_functions[count.index].invoke_arn
}

resource "aws_apigatewayv2_integration" "custom_integration" {
  count            = length(var.websocket_custom_routes)
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.websocket_custom_functions[count.index].invoke_arn
}

resource "aws_apigatewayv2_route" "routes" {
  count     = length(var.websocket_routes)
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = var.websocket_routes[count.index].route_key
  target    = "integrations/${aws_apigatewayv2_integration.integration[count.index].id}"
}

resource "aws_apigatewayv2_route" "custom_routes" {
  count     = length(var.websocket_custom_routes)
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = var.websocket_custom_routes[count.index].route_key
  target    = "integrations/${aws_apigatewayv2_integration.custom_integration[count.index].id}"
}

resource "aws_apigatewayv2_route_response" "route_responses" {
  count              = length(var.websocket_routes)
  api_id             = aws_apigatewayv2_api.websocket_api.id
  route_id           = aws_apigatewayv2_route.routes[count.index].id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route_response" "custom_route_responses" {
  count              = length(var.websocket_custom_routes)
  api_id             = aws_apigatewayv2_api.websocket_api.id
  route_id           = aws_apigatewayv2_route.custom_routes[count.index].id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  description = "Bettermort API deployment"
  depends_on  = [aws_apigatewayv2_route.routes, aws_apigatewayv2_integration.integration, aws_apigatewayv2_route_response.route_responses, aws_apigatewayv2_route.custom_routes, aws_apigatewayv2_integration.custom_integration, aws_apigatewayv2_route_response.custom_route_responses, ]

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_route.routes),
      jsonencode(aws_apigatewayv2_integration.integration),
      jsonencode(aws_apigatewayv2_route_response.route_responses),
      jsonencode(aws_apigatewayv2_route.custom_routes),
      jsonencode(aws_apigatewayv2_integration.custom_integration),
      jsonencode(aws_apigatewayv2_route_response.custom_route_responses),
    ])))
  }
  lifecycle {
    create_before_destroy = true
  }
}
