variable "dynamodb_table" {
  description = "Map of DynamoDB table definitions"
  type = map(object({
    name            = string
    billing_mode    = string
    hash_key        = string
    range_key       = optional(string)
    read_capacity   = optional(number)
    write_capacity  = optional(number)
    hash_key_type   = string
    range_key_type  = optional(string)
    tags            = optional(map(string))
  }))
}