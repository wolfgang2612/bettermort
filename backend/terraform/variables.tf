variable "websocket_routes" {
  default = [
    {
      route_key     = "$connect"
      function_name = "bettermort_connect_lambda"
    },
    {
      route_key     = "$disconnect"
      function_name = "bettermort_disconnect_lambda"
    }
  ]
}
