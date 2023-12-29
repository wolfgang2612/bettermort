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
    },
    {
      route_key     = "get_state"
      function_name = "get_state"
    }
  ]
}

variable "throttling_burst_limit" {
  type    = number
  default = 5
}

variable "throttling_rate_limit" {
  type    = number
  default = 10
}
