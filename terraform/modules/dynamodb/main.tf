resource "aws_dynamodb_table" "dynamodb_table" {
  for_each      = var.dynamodb_table
  name          = each.value.name
  billing_mode  = "PROVISIONED"
  hash_key      = each.value.hash_key
  range_key     = each.value.attribute_range_key
  read_capacity = each.value.read_capacity != null ? each.value.read_capacity : 1
  write_capacity = each.value.write_capacity != null ? each.value.write_capacity : 1

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
