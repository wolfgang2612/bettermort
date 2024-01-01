data "archive_file" "lambda_layer_file" {
  type        = "zip"
  source_dir  = "../lambda/layer"
  output_path = "../lambda/layer/layer.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.lambda_layer_file.output_path
  layer_name = "bettermort_lambda_layer"

  compatible_runtimes = [var.python_runtime]
}

data "archive_file" "lambda" {
  count       = length(var.websocket_routes)
  type        = "zip"
  source_dir  = "../lambda/${var.websocket_routes[count.index].function_name}"
  output_path = "../lambda/${var.websocket_routes[count.index].function_name}/${var.websocket_routes[count.index].function_name}.zip"
}

data "archive_file" "custom_lambda" {
  count       = length(var.websocket_custom_routes)
  type        = "zip"
  source_dir  = "../lambda/${var.websocket_custom_routes[count.index].function_name}"
  output_path = "../lambda/${var.websocket_custom_routes[count.index].function_name}/${var.websocket_custom_routes[count.index].function_name}.zip"
}


resource "aws_lambda_function" "websocket_functions" {
  count = length(var.websocket_routes)

  filename      = data.archive_file.lambda[count.index].output_path
  function_name = "bettermort_${var.websocket_routes[count.index].function_name}_lambda"

  role    = aws_iam_role.lambda_role.arn
  handler = "main.handler"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda[count.index].output_base64sha256
  runtime          = var.python_runtime
}

resource "aws_lambda_function" "websocket_custom_functions" {
  count = length(var.websocket_custom_routes)

  filename      = data.archive_file.custom_lambda[count.index].output_path
  function_name = "bettermort_${var.websocket_custom_routes[count.index].function_name}_lambda"

  role    = aws_iam_role.lambda_custom_role[count.index].arn
  handler = "main.handler"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.custom_lambda[count.index].output_base64sha256
  runtime          = var.python_runtime
}

resource "aws_lambda_permission" "lambda_permissions" {
  count         = length(var.websocket_routes)
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_functions[count.index].function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "custom_lambda_permissions" {
  count         = length(var.websocket_custom_routes)
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_custom_functions[count.index].function_name
  principal     = "apigateway.amazonaws.com"
}
