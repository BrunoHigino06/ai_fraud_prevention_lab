variable "dynamodb_table" {
  description = "Map of DynamoDB table definitions"
  type = map(object({
    name                     = string
    hash_key                 = string
    hash_key_type            = string
    attribute_range_key      = optional(string)
    attribute_range_key_type = optional(string)
    tags                     = optional(map(string))
  }))
}
