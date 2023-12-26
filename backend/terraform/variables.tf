variable "websocket_routes" {
  default = [
    {
      route_key     = "$connect"
      function_name = "bettermort_connect_lambda"
    },
    {
      route_key     = "$disconnect"
      function_name = "bettermort_disconnect_lambda"
    },
    {
      route_key     = "$default"
      function_name = "bettermort_default_lambda"
    },
    {
      route_key     = "get_state"
      function_name = "bettermort_get_state_lambda"
    }
  ]
}
