module "dynamodb_tables" {
  source = "./modules/dynamodb"

  dynamodb_table = {
    for key, dynamodb_table in var.dynamodb_table : key => {
      name                     = dynamodb_table.name
      hash_key                 = dynamodb_table.hash_key
      hash_key_type            = dynamodb_table.hash_key_type
      attribute_range_key      = dynamodb_table.attribute_range_key
      attribute_range_key_type = dynamodb_table.attribute_range_key_type
      read_capacity            = dynamodb_table.read_capacity
      write_capacity           = dynamodb_table.write_capacity
      tags                     = local.tags
    }
  }
}

locals {
  dynamodb_items = merge({}, [
    for table_key, table in var.table_itens : {
      for item in jsondecode(file("${path.module}/templates/dynamodb/${table.file_name}")) :
      jsonencode([table_key, item[table.hash_key]]) => {
        table_name = table.table_name
        hash_key   = table.hash_key
        item       = item
      }
    }
  ]...)
}

resource "aws_dynamodb_table_item" "table_itens" {
  for_each = local.dynamodb_items

  table_name = each.value.table_name
  hash_key   = each.value.hash_key
  item       = jsonencode(each.value.item)

  depends_on = [module.dynamodb_tables]
}
