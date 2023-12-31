resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "bettermort"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "lobby_code"

  attribute {
    name = "lobby_code"
    type = "S"
  }

  ttl {
    attribute_name = "time_to_live"
    enabled        = true
  }
}
