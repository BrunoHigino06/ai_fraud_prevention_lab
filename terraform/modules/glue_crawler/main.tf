resource "aws_glue_crawler" "glue_crawler" {
  for_each      = var.glue_crawler
  name          = each.value.name
  database_name = each.value.database_name
  role          = each.value.role
  description   = each.value.description
  dynamodb_target {
    path = each.value.table_name
  }
  tags = var.glue_crawler.tags
}