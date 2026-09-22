module "dynamodb_tables" {
  source = "./modules/dynamodb"

  dynamodb_table = {
    for dynamodb_table in var.dynamodb_table : dynamodb_table => {
      name                     = dynamodb_table.name
      hash_key                 = dynamodb_table.hash_key
      range_key                = dynamodb_table.range_key
      read_capacity            = dynamodb_table.read_capacity
      write_capacity           = dynamodb_table.write_capacity
      attribute_range_key      = dynamodb_table.attribute_range_key
      attribute_range_key_type = dynamodb_table.attribute_range_key_type
      tags                     = var.tags
    }
  }
}