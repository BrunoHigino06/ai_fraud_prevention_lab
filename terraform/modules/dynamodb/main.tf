resource "aws_dynamodb_table" "dynamodb_table" {
  for_each  = var.dynamodb_table
  name      = each.value.name
  hash_key  = each.value.hash_key
  range_key = each.value.attribute_range_key

  attribute {
    name = each.value.hash_key
    type = each.value.hash_key_type
  }

  dynamic "attribute" {
    for_each = each.value.attribute_range_key != null ? [each.value.attribute_range_key] : []
    content {
      name = each.value.attribute_range_key
      type = each.value.attribute_range_key_type
    }
  }

  tags = each.value.tags

}
