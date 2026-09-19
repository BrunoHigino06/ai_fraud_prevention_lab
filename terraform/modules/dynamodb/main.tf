resource "aws_dynamodb_table" "dynamodb_table" {
  for_each       = var.dynamodb_table
  name           = each.value.name
  billing_mode   = each.value.billing_mode
  hash_key       = each.value.hash_key
  range_key      = each.value.range_key
  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity

  attribute {
    name = each.value.hash_key
    type = each.value.hash_key_type
  }

  dynamic "attribute" {
    for_each = each.value.range_key != null ? [each.value.range_key] : []
    content {
      name = attribute.value
      type = each.value.range_key_type
    }
  }

  tags = var.dynamodb_table.tags
  
}