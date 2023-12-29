data "archive_file" "lambda" {
  for_each    = { for idx, value in var.websocket_routes : idx => value }
  type        = "zip"
  source_dir  = "../lambda/${each.value.function_name}"
  output_path = "../lambda/${each.value.function_name}/${each.value.function_name}.zip"
}


resource "aws_lambda_function" "websocket_functions" {
  for_each = { for idx, value in var.websocket_routes : idx => value }

  filename      = "../lambda/${each.value.function_name}/${each.value.function_name}.zip"
  function_name = "bettermort_${each.value.function_name}_lambda"

  role    = aws_iam_role.lambda_role.arn
  handler = "main.handler"

  source_code_hash = data.archive_file.lambda[each.key].output_base64sha256
  runtime          = "python3.8"
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = { for idx, value in var.websocket_routes : idx => value }
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
}
