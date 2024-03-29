variable "websocket_routes" {
  default = [
    {
      route_key     = "$connect"
      function_name = "connect"
    },
    {
      route_key     = "$disconnect"
      function_name = "disconnect"
    },
    {
      route_key     = "$default"
      function_name = "default"
    }
  ]
}

variable "websocket_custom_routes" {
  default = [
    {
      route_key     = "create_lobby"
      function_name = "create_lobby"
      permissions   = ["dynamodb:GetItem", "dynamodb:PutItem"]
      resources     = ["arn:aws:dynamodb:*:647256487653:table/bettermort*"]
    },
    {
      route_key     = "join_lobby"
      function_name = "join_lobby"
      permissions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
      resources     = ["arn:aws:dynamodb:*:647256487653:table/bettermort*"]
    },
    {
      route_key     = "kick_player"
      function_name = "kick_player"
      permissions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
      resources     = ["arn:aws:dynamodb:*:647256487653:table/bettermort*"]
    },
    {
      route_key     = "get_state"
      function_name = "get_state"
      permissions   = ["dynamodb:GetItem"]
      resources     = ["arn:aws:dynamodb:*:647256487653:table/bettermort*"]
    }
  ]
}

variable "throttling_burst_limit" {
  type    = number
  default = 10
}

variable "throttling_rate_limit" {
  type    = number
  default = 10
}

variable "python_runtime" {
  type    = string
  default = "python3.11"
}
