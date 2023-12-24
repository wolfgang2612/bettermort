resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "bettermort"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
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


