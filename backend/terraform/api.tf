resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "bettermort"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.websocket_api.id
  name   = "bettermort-stage"
}

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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  for_each    = { for idx, value in var.websocket_routes : idx => value }
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/${each.value.function_name}"
  output_path = "${path.module}/lambda_functions/${each.value.function_name}/${each.value.function_name}.zip"
}


resource "aws_lambda_function" "websocket_functions" {
  for_each = { for idx, value in var.websocket_routes : idx => value }

  filename      = "${path.module}/lambda_functions/${each.value.function_name}/${each.value.function_name}.zip"
  function_name = each.value.function_name

  role    = aws_iam_role.iam_for_lambda.arn
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda[each.key].output_base64sha256
  runtime          = "python3.8"
}

resource "aws_apigatewayv2_integration" "integration" {
  for_each         = { for idx, value in var.websocket_routes : idx => value }
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.websocket_functions[each.key].invoke_arn
}

resource "aws_apigatewayv2_route" "routes" {
  for_each  = { for idx, value in var.websocket_routes : idx => value }
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.integration[each.key].id}"
}

resource "aws_apigatewayv2_route_response" "route_responses" {
  for_each           = { for idx, value in var.websocket_routes : idx => value }
  api_id             = aws_apigatewayv2_api.websocket_api.id
  route_id           = aws_apigatewayv2_route.routes[each.key].id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_deployment" "example" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  description = "Bettermort deployment"
  depends_on  = [aws_apigatewayv2_route.routes, aws_apigatewayv2_integration.integration, aws_apigatewayv2_route_response.route_responses]

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_route.routes),
      jsonencode(aws_apigatewayv2_integration.integration),
      jsonencode(aws_apigatewayv2_route_response.route_responses),
    ])))
  }
  lifecycle {
    create_before_destroy = true
  }
}
